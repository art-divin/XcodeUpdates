//
//  Output.swift
//  XcodeUpdatesInternal
//
//  Created by Ruslan Alikhamov on 22.11.2020.
//

import Foundation

public enum OutputError : Error {
    case generalError(Output)
    case anotherVersionIsBeingInstalled
}

public struct Output {
    
    internal var first : ListModel? {
        self.contents.first
    }
    
    public var latest : ListModel? {
        self.contents.last
    }
    
    public var contents : [ListModel] {
        self.content.components(separatedBy: .newlines).filter { !$0.isEmpty }.compactMap { ListModel(content: $0) }
    }
    internal var content : String
    
}
