//
//  XcodeUpdatesResponse.swift
//  XcodeUpdatesInternal
//
//  Created by Ruslan Alikhamov on 22.11.2020.
//

import Foundation

public enum XcodeUpdatesResponseType {
    
    case none
    case list
    case auth
    case twoFA
    case installed
    case status(String)
    case removedXip
    case cannotRemoveXip
    case downloaded(String)
    case unauthorized
    case error

}

public struct XcodeUpdatesResponse {
    
    public var type : XcodeUpdatesResponseType
    public var list : [ListModel]?
    
    public init(output: Output) {
        self.type = output.contents.first?.type ?? .list
        self.list = output.contents
    }
    
}
