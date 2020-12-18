//
//  XcodesWrapper.swift
//  XcodeUpdatesInternal
//
//  Created by Ruslan Alikhamov on 18.11.2020.
//

import Foundation
import Combine

// TODO: move to an XPC service
// serve as an operation instead of just a class
class XcodesWrapper {
    
    enum Constants {
        static let xcodes = "xcodes"
        static let aria2c = "aria2c"
    }
    
    private var url : URL {
        guard let url = Bundle(for: XcodesWrapper.self).url(forResource: Constants.xcodes, withExtension: nil) else {
            fatalError("invalid bundle!")
        }
        return url
    }
    
    internal static var aria2cPath : String {
        guard let url = Bundle(for: XcodesWrapper.self).url(forResource: Constants.aria2c, withExtension: nil) else {
            fatalError("invalid bundle!")
        }
        return url.path
    }
    
    internal let output : PassthroughSubject<Output, OutputError> = .init()
    internal let input : PassthroughSubject<Input, Never> = .init()
    
    private var writeHandle : FileHandle?
    private var readHandle : FileHandle?
    private var errorHandle : FileHandle?

    private var cancellables : [AnyCancellable] = []
    private var process : Process = Process()
    private var outputData : Data?
    private var formattedOutput : Output {
        let string = String(data: self.outputData ?? Data(), encoding: .utf8) ?? ""
        return Output(content: string)
    }
    private var request : XcodeUpdatesRequest
    
    init(request: XcodeUpdatesRequest) {
        self.request = request
        self.setup()
    }
    
    private func setup() {
        self.input.sink { [weak self] in
            guard var input = $0.input else {
                return
            }
            input.append("\n")
            guard let data = input.data(using: .utf8) else { return }
            self?.outputData = nil
            self?.writeHandle?.write(data)
        }.store(in: &self.cancellables)
        self.request.isCancelled.sink {
            if $0 {
                self.process.terminate()
            }
        }.store(in: &self.cancellables)
    }
    
    private func close() {
        self.errorHandle?.readabilityHandler = nil
        self.writeHandle?.writeabilityHandler = nil
        self.readHandle?.readabilityHandler = nil
        self.errorHandle?.closeFile()
        self.readHandle?.closeFile()
        self.writeHandle?.closeFile()
    }
    
    private var processArgs : [String] {
        guard let input = self.request.popFirst() else {
            return []
        }
        var arguments = input.args
        if let input = input.input {
            arguments.append(input)
        }
        return arguments
    }
    
    private func sendOutput() {
        DispatchQueue.main.async {
            let formattedOutput = self.formattedOutput
            if let output = self.request.output {
                switch formattedOutput.first?.type {
                    case .error?:
                        output.send(.failure(.generalError(formattedOutput)))
                    default:
                        output.send(.success(formattedOutput))
                }
            } else {
                self.output.send(formattedOutput)
            }
        }
    }
    
    func run() {
        DispatchQueue.global().async {
            let readPipe = Pipe()
            let writePipe = Pipe()
            let errorPipe = Pipe()
            self.writeHandle = writePipe.fileHandleForWriting
            self.readHandle = readPipe.fileHandleForReading
            self.errorHandle = errorPipe.fileHandleForReading
            self.process.standardInput = writePipe
            self.process.standardOutput = readPipe
            self.process.standardError = errorPipe
            self.process.executableURL = self.url
            self.process.arguments = self.processArgs
            do {
                try self.process.run()
                self.process.terminationHandler = { _ in
                    self.outputData = (self.outputData ?? Data()) + (self.readHandle?.availableData ?? Data())
                    print("XXX: output: \(self.formattedOutput)")
                    self.sendOutput()
                    self.close()
                }
                self.readHandle?.readabilityHandler = {
                    let data = $0.availableData
                    if data.isEmpty {
                        return
                    }
                    self.outputData = (self.outputData ?? Data()) + data
                    self.sendOutput()
                }
                self.errorHandle?.readabilityHandler = {
                    let data = $0.availableData
                    if data.isEmpty {
                        return
                    }
                    let error = String(data: data, encoding: .utf8)
                    if error?.contains("[logging]") ?? true {
                        return
                    }
                    self.outputData = (self.outputData ?? Data()) + data
                    self.sendOutput()
                }
                self.process.waitUntilExit()
            } catch {
                print(error)
            }
        }
    }
    
}
