//
//  RequestFactory.swift
//  XcodeUpdatesInternal
//
//  Created by Ruslan Alikhamov on 21.11.2020.
//

import Foundation

public struct RequestFactory {
    
    enum Constants {
        static let install = "install"
        static let update = "update"
        static let select = "select"
        static let uninstall = "uninstall"
        static let list = "list"
        static let aria2c = "--aria2"
        static let printDates = "--print-dates"
        static let version = "version"
        static let download = "download"
        static let remove = "remove"
        static let path = "--path"
        static let output = "--output"
        static let json = "json"
        static let downloadList = "--list"
        static let installationPath = "--install-path"
        static let unauthorize = "unauthorize"
    }
    
    public static func install(version: String, savedPath: URL?, unarchiveURL: URL?) -> XcodeUpdatesRequest {
        var args = [Constants.install, version]
        if let path = savedPath {
            args += [Constants.path, path.path]
        }
        if let unarchiveURL = unarchiveURL {
            args += [Constants.installationPath, unarchiveURL.path]
        }
        let input = Input(args: args)
        let request = XcodeUpdatesRequest(input: [input])
        return request
    }
    
    public static func download(version: String, savedPath: URL?) -> XcodeUpdatesRequest {
        var args = [Constants.download, version, Constants.aria2c, XcodesWrapper.aria2cPath ]
        if let url = savedPath {
            args += [ Constants.path, url.appendingPathComponent(version).path.replacingOccurrences(of: " ", with: "-").appending(".xip") ]
        }
        args += [ Constants.output, Constants.json ]
        let input = Input(args: args)
        let request = XcodeUpdatesRequest(input: [input])
        return request
    }
    
    public static func list(searchPath: URL?) -> XcodeUpdatesRequest {
        var args = [Constants.list, Constants.printDates]
        if let path = searchPath {
            args += [Constants.path, path.path]
        }
        let input = Input(args: args)
        let request = XcodeUpdatesRequest(input: [input])
        return request
    }
    
    public static func update(searchPath: URL?) -> XcodeUpdatesRequest {
        var args = [Constants.update, Constants.printDates]
        if let path = searchPath {
            args += [Constants.path, path.path]
        }
        let input = Input(args: args)
        let request = XcodeUpdatesRequest(input: [input])
        return request
    }
    
    public static func version() -> XcodeUpdatesRequest {
        let input = Input(args: [Constants.version])
        let request = XcodeUpdatesRequest(input: [input])
        return request
    }
    
    public static func deleteXip(version: String, savedPath: URL?) -> XcodeUpdatesRequest {
        var args = [ Constants.remove, version ]
        if let url = savedPath {
            args += [ Constants.path, url.path ]
        }
        let input = Input(args: args)
        let request = XcodeUpdatesRequest(input: [input])
        return request
    }
    
    public static func unauthorize() -> XcodeUpdatesRequest {
        let args = [ Constants.unauthorize ]
        let input = Input(args: args)
        let request = XcodeUpdatesRequest(input: [input])
        return request
    }
    
}
