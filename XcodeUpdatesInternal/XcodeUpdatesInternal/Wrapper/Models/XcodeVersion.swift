//
//  XcodeVersion.swift
//  XcodeUpdates
//
//  Created by Ruslan Alikhamov on 27.11.2020.
//

import Foundation
import SwiftUI

extension DateFormatter {
    
    static var releaseDateFormatter : DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        return dateFormatter
    }
    
}

public struct XcodeVersion : Identifiable, Hashable {
    
    public static func == (lhs: XcodeVersion, rhs: XcodeVersion) -> Bool {
        lhs.name == rhs.name
    }
    
    public var id : String {
        self.name
    }
    
    public var isNew : Bool = false
    public var name: String
    public var isInstalled : Bool = false
    public var isSelected : Bool = false
    public var isDownloaded : Bool = false
    public var isUnfinished : Bool = false
    public var releaseDate : Date?
    public var releaseDateStr : String {
        guard let releaseDate = self.releaseDate else {
            return "Unknown"
        }
        return DateFormatter.releaseDateFormatter.string(from: releaseDate)
    }
    
    private var formatter : DateFormatter {
        DateFormatter.releaseDateFormatter
    }
    
    public init(name: String) {
        self.isInstalled = name.contains(Constants.installed)
        self.isSelected = name.contains(Constants.selected)
        self.isDownloaded = name.contains(Constants.downloaded)
        self.isUnfinished = name.contains(Constants.unfinished)
        self.isNew = name.contains(Constants.isNew)
        self.name = name.name
        self.releaseDate = name.releaseDate
    }
    
    private enum Constants {
        static let installed = "Installed"
        static let selected = "Selected"
        static let downloaded = "Downloaded"
        static let unfinished = "Unfinished"
        static let isNew = "New"
    }
    
}

extension String {
    
    var name : Self {
        let comps = self.components(separatedBy: "(").map { $0.trimmingCharacters(in: .whitespaces) }
        return comps.first ?? ""
    }

    var releaseDate : Date? {
        let comps = self.components(separatedBy: "(").map { $0.trimmingCharacters(in: .whitespaces) }.map { $0.trimmingCharacters(in: .punctuationCharacters) }
        guard let date = comps.last else {
            return nil
        }
        return DateFormatter.releaseDateFormatter.date(from: date)
    }
    
}
