//
//  XcodeUpdatesServiceDelegate.swift
//  XcodeUpdatesService
//
//  Created by Ruslan Alikhamov on 03.01.2021.
//  Copyright © 2021 Ruslan Alikhamov. All rights reserved.
//

import Foundation
import XcodeUpdatesInternal

// (c) https://matthewminer.com/2018/08/25/creating-an-xpc-service-in-swift
class XcodeUpdatesServiceDelegate: NSObject, NSXPCListenerDelegate {
    
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        let exportedObject = XcodeUpdatesService(connection: newConnection)
        newConnection.exportedInterface = NSXPCInterface(with: XcodeUpdatesServiceProtocol.self)
        newConnection.exportedObject = exportedObject
        newConnection.resume()
        return true
    }
    
}
