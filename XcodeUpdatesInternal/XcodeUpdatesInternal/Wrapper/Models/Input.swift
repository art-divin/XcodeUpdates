//
//  Input.swift
//  XcodeUpdatesInternal
//
//  Created by Ruslan Alikhamov on 22.11.2020.
//

import Foundation

public struct Input {
    
    enum EncodingKeys {
        static let input = "input"
        static let args = "args"
    }
    
    public static func encode(_ input: Self) -> [String : Any] {
        var retVal : [String : Any] = [:]
        retVal[EncodingKeys.input] = input.input
        retVal[EncodingKeys.args] = input.args
        return retVal
    }
    
    public static func decode(_ input: [String : Any]) -> Self {
        let args = input[EncodingKeys.args] as? [String] ?? []
        let input = input[EncodingKeys.input] as? String
        let retVal = Input(args: args, input: input)
        return retVal
    }
    
//
//    public static var supportsSecureCoding: Bool { true }
//
//    public func encode(with coder: NSCoder) {
//        coder.encode(self.input, forKey: EncodingKeys.input)
//        coder.encode(self.args, forKey: EncodingKeys.args)
//    }
//
//    public required init?(coder: NSCoder) {
//        guard let input = coder.decodeObject(of: [NSString.self], forKey: EncodingKeys.input) as? String,
//              let args = coder.decodeObject(of: [NSArray.self, NSString.self], forKey: EncodingKeys.args) as? [String] else
//        {
//            return nil
//        }
//        self.input = input
//        self.args = args
//    }
    
    public var args : [String]
    public var input : String?
    
    public init(args: [String] = [], input: String? = nil) {
        self.args = args
        self.input = input
    }
    
}
