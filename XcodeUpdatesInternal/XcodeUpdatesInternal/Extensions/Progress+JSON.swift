//
//  Progress+JSON.swift
//  XcodesKit
//
//  Created by Ruslan Alikhamov on 12.12.2020.
//

import Foundation

extension Progress {
    
    private enum Constants {
        static let estimatedTimeRemaining = "estimatedTimeRemaining"
        static let throughput = "throughput"
        static let totalUnitCount = "totalUnitCount"
        static let completedUnitCount = "completedUnitCount"
    }
    
    private var serialized : [String : Any?] {
        [ Constants.estimatedTimeRemaining : self.estimatedTimeRemaining,
          Constants.throughput : self.throughput,
          Constants.totalUnitCount : self.totalUnitCount,
          Constants.completedUnitCount : self.completedUnitCount ]
    }
    
    var base64EncodedJSON : String? {
        try? JSONSerialization.data(withJSONObject: self.serialized, options: []).base64EncodedString()
    }
    
    func fromBase64Encoded(string : String) {
        guard let data = Data(base64Encoded: string) else { return }
        guard let object = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] else { return }
        self.estimatedTimeRemaining = object[Constants.estimatedTimeRemaining] as? TimeInterval
        self.throughput = object[Constants.throughput] as? Int
        self.totalUnitCount = object[Constants.totalUnitCount] as? Int64 ?? 0
        self.completedUnitCount = object[Constants.completedUnitCount] as? Int64 ?? 0
    }
    
}
