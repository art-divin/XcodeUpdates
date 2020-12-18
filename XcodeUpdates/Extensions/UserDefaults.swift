//
//  UserDefaults.swift
//  XcodeUpdates
//
//  Created by Ruslan Alikhamov on 28.11.2020.
//

import Foundation

extension UserDefaults {
    
    var downloadsURL : URL? {
        get {
            guard let saved = self.string(forKey: #function) else {
                return nil
            }
            return URL(fileURLWithPath: saved)
        }
        set {
            self.setValue(newValue?.path, forKey: #function)
        }
    }
    
    var unarchiveURL : URL? {
        get {
            guard let saved = self.string(forKey: #function) else {
                return nil
            }
            return URL(fileURLWithPath: saved)
        }
        set {
            self.setValue(newValue?.path, forKey: #function)
        }
    }
    
}
