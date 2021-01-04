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
    case password
    case twoFA
    case installed
    case status(String)
    case removedXip
    case cannotRemoveXip
    case downloaded(String)
    case unauthorized
    case error

}

public class XcodeUpdatesResponse : NSObject, NSSecureCoding {
    
    enum EncodingKeys {
        static let output = "output"
    }
    
    public static var supportsSecureCoding: Bool { true }
    
    public func encode(with coder: NSCoder) {
        coder.encode(self.output, forKey: EncodingKeys.output)
    }
    
    public required init?(coder: NSCoder) {
        guard let output = coder.decodeObject(of: [Output.self], forKey: EncodingKeys.output) as? Output else {
            return nil
        }
        self.output = output
    }
    
    public var type : XcodeUpdatesResponseType {
        self.output.contents.first?.type ?? .list
    }
    public var list : [ListModel]? {
        self.output.contents
    }
    
    private var output : Output
    
    public init(output: Output) {
        self.output = output
    }
    
}
