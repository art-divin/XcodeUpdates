//
//  ListModel.swift
//  XcodeUpdatesInternal
//
//  Created by Ruslan Alikhamov on 19.11.2020.
//

import Foundation

extension XcodeUpdatesResponseType {
    
    enum Constants {
        static let authPassword = "Apple ID Password:"
        static let auth = "Apple ID:"
        static let invalidUsername = "Invalid username and password combination. Attempted to sign in with username"
        static let twoFA = "Two-factor authentication is enabled for this account."
        static let status = "\u{1B}[1A\u{1B}[K"
        static let unarchiveStatus = "(2/6) Unarchiving Xcode (This can take a while)"
        static let movingUnarchivedStatus = "(3/6) Moving Xcode to"
        static let movingXipToTrashStatus = "(4/6) Moving Xcode archive"
        static let checkingSecurity = "(5/6) Checking security assessment and code signing"
        static let removedXip = "moved to Trash:"
        static let cannotRemoveXip = "There are no downloaded XIPs available"
        static let removeXipCandidates = "could not be found. Possible candidates for removal"
        static let failedExecuting = "Failed executing:"
        static let xipFailure = "xip:"
        static let xipFailure2 = "Error Domain="
        static let xipFailure3 = "xip: error:"
        static let aria2cGenericError = "aria2c error:"
        static let aria2cNotEnoughSpace2Error = "CantOpenExclusive: errno"
        static let httpError = "Error Domain="
        static let executionFailure = "Failed executing:"
        static let downloaded = "has been downloaded to"
        static let unauthorized = "Stored username and password have been removed"
    }
   
    init?(string: String, parsed: String?) {
        if string.hasPrefix(Constants.auth) || string.hasPrefix(Constants.authPassword) {
            self = .auth
        } else if string.hasPrefix(Constants.invalidUsername) {
            self = .error
        } else if string.hasPrefix(Constants.twoFA) {
            self = .twoFA
        } else if string == Constants.unauthorized {
            self = .unauthorized
        } else if string.contains(Constants.downloaded) {
            self = .downloaded(parsed ?? string)
        } else if string.hasPrefix(Constants.checkingSecurity) {
            self = .installed
        } else if string.hasPrefix(Constants.status) ||
                    string == Constants.unarchiveStatus ||
                    string.hasPrefix(Constants.movingUnarchivedStatus)
        {
            self = .status(parsed ?? string)
        } else if string.contains(Constants.removedXip) {
            self = .removedXip
        } else if string.contains(Constants.cannotRemoveXip) || string.contains(Constants.removeXipCandidates) {
            self = .cannotRemoveXip
        } else if string.contains(Constants.failedExecuting) ||
                    string.hasPrefix(Constants.xipFailure) ||
                    string.contains(Constants.xipFailure2) ||
                    string.contains(Constants.xipFailure3) ||
                    string.hasPrefix(Constants.aria2cGenericError) ||
                    string.contains(Constants.aria2cNotEnoughSpace2Error) ||
                    string.contains(Constants.httpError) ||
                    string.contains(Constants.executionFailure)
        {
            self = .error
        } else {
            self = .list
        }
    }
    
}

// TODO:
// there should be an established communication protocol between the output of `xcodes` and ListModel
// say, json can be requested for all of the output, and that output would be then parsed here to create specific types
// of the response models 
public struct ListModel : Identifiable {
    
    public var type : XcodeUpdatesResponseType
        
    public var id : String { self.content }
    public let content : String
    
    // TODO: move to separate subclass specific to status type of response
    public var progress : String? {
        guard case .status(_) = self.type else { return nil }
        let comps = self.content.components(separatedBy: ":")
        return comps.last?.replacingOccurrences(of: " ", with: "")
    }
    
    public var status : String? {
        guard case .status(_) = self.type else { return nil }
        let comps = self.content.components(separatedBy: ":")
        return comps.first
    }
    
    public init?(content: String) {
        var parsed = content
        if parsed.hasPrefix(Constants.garbage) {
            parsed.removeFirst(Constants.garbage.count)
        }
        self.content = parsed
        let comps = self.content.components(separatedBy: ":")
        let status = comps.first
        guard let type = XcodeUpdatesResponseType(string: content, parsed: status) else { return nil }
        self.type = type
    }
    
    enum Constants {
        static let garbage = "\u{1B}[1A\u{1B}[K"
        static let percentDataCount = 5
    }
    
}
