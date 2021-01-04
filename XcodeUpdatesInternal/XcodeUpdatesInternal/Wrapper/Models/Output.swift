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

public class Output : NSObject, NSSecureCoding {
    
    enum EncodingKeys {
        static let content = "content"
    }
    
    public static var supportsSecureCoding: Bool { true }
    
    public func encode(with coder: NSCoder) {
        coder.encode(self.content, forKey: EncodingKeys.content)
    }
    
    public required init?(coder: NSCoder) {
        guard let content = coder.decodeObject(of: [NSString.self], forKey: EncodingKeys.content) as? String else {
            return nil
        }
        self.content = content
    }
    
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
    
    init(content: String) {
        self.content = content
    }
    
}
