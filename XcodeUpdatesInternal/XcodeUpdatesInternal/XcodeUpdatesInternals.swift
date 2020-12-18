//
//  XcodeUpdatesInternals.swift
//  XcodeUpdatesInternal
//
//  Created by Ruslan Alikhamov on 18.11.2020.
//

import Foundation
import Combine

public class XcodeUpdatesInternals {
    
    public init() {}
    
    private var wrapper : XcodesWrapper?
    private var cancellables : [AnyCancellable] = []
    
    private var currentRequest : XcodeUpdatesRequest?
    private var currentInput : Input? {
        self.currentRequest?.popFirst()
    }
    
    public let output : PassthroughSubject<XcodeUpdatesResponse, Never> = .init()
    public let input : PassthroughSubject<XcodeUpdatesRequest, Never> = .init()
    
    // TODO:
    // This should spawn an NSOperation
    public func reloadExec(_ request: XcodeUpdatesRequest) {
        self.currentRequest = request
        // TODO: account for all input in the request
        self.wrapper = XcodesWrapper(request: request)
        self.wrapper?.output.receive(on: DispatchQueue.main).sink(receiveCompletion: {
            print("error: \($0)")
        }, receiveValue:{
            self.process(output: $0)
        })
        .store(in: &self.cancellables)
        self.input.sink {
            _ = self.process(request: $0)
        }.store(in: &self.cancellables)
        self.wrapper?.run()
    }
    
    private func process(request: XcodeUpdatesRequest) -> Bool {
        self.currentRequest = request
        if let currentInput = self.currentInput {
            // send existing input back
            self.wrapper?.input.send(currentInput)
            return true
        }
        return false
    }
    
    private func process(output: Output) {
        switch output.first?.type {
            case .twoFA?: fallthrough
            case .error?: self.currentRequest = nil
            default:
                if let request = self.currentRequest {
                    if self.process(request: request) {
                        return
                    }
                }
        }
        self.output.send(
            XcodeUpdatesResponse(output: output)
        )
    }
    
}
