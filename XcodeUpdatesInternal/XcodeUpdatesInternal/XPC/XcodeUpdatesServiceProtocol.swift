//
//  XcodeUpdatesServiceProtocol.h
//  XcodeUpdatesService
//
//  Created by Ruslan Alikhamov on 03.01.2021.
//  Copyright © 2021 Ruslan Alikhamov. All rights reserved.
//

import Foundation

@objc public protocol XcodeUpdatesServiceProtocol {

    func fetchXcodeList(url: URL?)
    func authenticate(challenge: [[String : Any]])
    func sendTwoFA(challenge: [[String : Any]])
    func sendPassword(challenge: [[String : Any]])
    
}

@objc public protocol XPCWrapperProtocol {
    
    func sink(response: XcodeUpdatesResponse)
    
}
