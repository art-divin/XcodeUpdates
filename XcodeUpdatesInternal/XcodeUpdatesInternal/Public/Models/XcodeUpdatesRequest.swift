//
//  XcodeUpdatesRequest.swift
//  XcodeUpdatesInternal
//
//  Created by Ruslan Alikhamov on 22.11.2020.
//

import Foundation
import Combine

public class XcodeUpdatesRequest : Identifiable {
    
    public var id: String {
        self.identifier
    }
    
    public func isProcessing(version: String) -> Bool {
        return self.identifier.contains(" \(version) ")
    }
    
    private var cancellables : [AnyCancellable] = []
    public private(set) var isCancelled : CurrentValueSubject<Bool, Never> = .init(false)
    
    private var identifier : String
    public private(set) var input : [Input]
    public var output: PassthroughSubject<Result<Output, OutputError>, Never>? = nil {
        didSet {
            self.output?.sink(receiveCompletion: { _ in
            }, receiveValue: { [self] in
                switch $0 {
                    case .success(let output):
                        if let progress = output.latest?.progress {
                            self.progress.fromBase64Encoded(string: progress)
                        }
                    case .failure(let error):
                        print(error)
                }
            }).store(in: &self.cancellables)
        }
    }
    public var progress : Progress
    
    func popFirst() -> Input? {
        guard !self.input.isEmpty else { return nil }
        return self.input.remove(at: 0)
    }
    
    public init(input: [Input]) {
        guard !input.isEmpty else { fatalError("invalid arguments!") }
        self.input = input
        let progress = Progress()
        progress.kind = .file
        self.progress = progress
        self.identifier = self.input.compactMap { $0.args.joined(separator: " ") }.joined(separator: " ")
    }
    
}
