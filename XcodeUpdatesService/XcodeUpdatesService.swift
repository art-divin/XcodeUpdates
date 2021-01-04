//
//  XcodeUpdatesService.m
//  XcodeUpdatesService
//
//  Created by Ruslan Alikhamov on 03.01.2021.
//  Copyright © 2021 Ruslan Alikhamov. All rights reserved.
//

import Foundation
import XcodeUpdatesInternal
import Combine

class XcodeUpdatesService : XcodeUpdatesServiceProtocol {
    
    private var internals = XcodeUpdatesInternals()
    private var collectables : [AnyCancellable] = []
    let connection : NSXPCConnection
    
    init(connection: NSXPCConnection) {
        self.connection = connection
        self.connection.remoteObjectInterface = NSXPCInterface(with: XPCWrapperProtocol.self)
    }
    
    private func sink(response: XcodeUpdatesResponse) {
        let service = self.connection.remoteObjectProxyWithErrorHandler {
            print("internal XPC error: \($0)")
        } as? XPCWrapperProtocol
        service?.sink(response: response)
    }
    
    func fetchXcodeList(url: URL?) {
        self.internals.reloadExec(RequestFactory.update(searchPath: url))
        self.internals.output.sink { [weak self] in
            self?.sink(response: $0)
        }.store(in: &self.collectables)
    }
    
    private func send(challenge: [[String : Any]]) {
        let input = challenge.map { Input.decode($0) }
        let request = XcodeUpdatesRequest(input: input)
        self.internals.input.send(request)
    }
    
    func authenticate(challenge: [[String : Any]]) {
        self.send(challenge: challenge)
    }
    
    func sendTwoFA(challenge: [[String : Any]]) {
        self.send(challenge: challenge)
    }
    
    func sendPassword(challenge: [[String : Any]]) {
        self.send(challenge: challenge)
    }
    
}
