//
//  XPCWrapper.swift
//  XcodeUpdates
//
//  Created by Ruslan Alikhamov on 03.01.2021.
//  Copyright © 2021 Ruslan Alikhamov. All rights reserved.
//

import Foundation
import XcodeUpdatesInternal

class XPCWrapper : XPCWrapperProtocol {
    
    enum Constants {
        static let serviceIdentifier = "com.xcodeupdates.app.XcodeUpdates.XcodeUpdatesService"
    }
    
    lazy var connection : NSXPCConnection = {
        let connection = NSXPCConnection(serviceName: Constants.serviceIdentifier)
        connection.remoteObjectInterface = NSXPCInterface(with: XcodeUpdatesServiceProtocol.self)
        connection.exportedInterface = NSXPCInterface(with: XPCWrapperProtocol.self)
        connection.exportedObject = self
        connection.resume()
        return connection
    }()
    
    var sink : ((XcodeUpdatesResponse) -> Void)?
    
    init(sink: @escaping (XcodeUpdatesResponse) -> Void) {
        self.sink = sink
    }
    
    func sink(response: XcodeUpdatesResponse) {
        self.sink?(response)
    }
    
    var service : XcodeUpdatesServiceProtocol? {
        let service = self.connection.remoteObjectProxyWithErrorHandler {
            print($0)
        } as? XcodeUpdatesServiceProtocol
        return service
    }
      
    func fetchXcodeList(url: URL?) {
        self.service?.fetchXcodeList(url: url)
    }
    
    func authenticate(challenge: [Input]) {
        self.service?.authenticate(challenge: challenge.reduce(into: [[String : Any]]()) {
            $0.append(Input.encode($1))
        })
    }
    
    func sendTwoFA(challenge: [Input]) {
        self.service?.sendTwoFA(challenge: challenge.reduce(into: [[String : Any]]()) {
            $0.append(Input.encode($1))
        })
    }
    
    func sendPassword(challenge: [Input]) {
        self.service?.sendPassword(challenge: challenge.reduce(into: [[String : Any]]()) {
            $0.append(Input.encode($1))
        })
    }
        
}
