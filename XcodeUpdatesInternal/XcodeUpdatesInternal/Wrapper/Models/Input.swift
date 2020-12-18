//
//  Input.swift
//  XcodeUpdatesInternal
//
//  Created by Ruslan Alikhamov on 22.11.2020.
//

import Foundation

public struct Input {
    
    public var args : [String]
    public var input : String?
    
    public init(args: [String] = [], input: String? = nil) {
        self.args = args
        self.input = input
    }
    
}
