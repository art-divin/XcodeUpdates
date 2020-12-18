//
//  Preferences.swift
//  XcodeUpdates
//
//  Created by Ruslan Alikhamov on 27.11.2020.
//

import AppKit
import SwiftUI
import Combine

struct Preferences_AppKit: NSViewRepresentable {
    
    private(set) var saveAction : CurrentValueSubject<(() -> PreferencesPaths)?, Never> = .init(nil)
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
        // no-op
    }
    
    func makeNSView(context: Context) -> some NSView {
        let controller = PreferencesController(nibName: "Preferences", bundle: nil)
        self.saveAction.send({ controller.paths })
        return controller.view
    }
    
}

struct PreferencesPaths {
    
    var downloadsPath : URL?
    var unarchivePath : URL?
    
}

class PreferencesController : NSViewController {
    
    @IBOutlet var downloadsPath : NSPathControl!
    @IBOutlet var unarchivePath : NSPathControl!
    
    var paths : PreferencesPaths {
        PreferencesPaths(downloadsPath: self.downloadsPath.url, unarchivePath: self.unarchivePath.url)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    private func setup() {
        guard var defaultURL = try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            print("error accessing application support directory")
            return
        }
        defaultURL.appendPathComponent("com.xcodeupdates.app.XcodeUpdates")
        
        self.unarchivePath.url = self.stored(\.unarchiveURL) ?? defaultURL
        self.downloadsPath.url = self.stored(\.downloadsURL) ?? defaultURL
    }
    
    private func stored(_ keyPath: KeyPath<UserDefaults, URL?>) -> URL? {
        return UserDefaults.standard[keyPath: keyPath]
    }
    
}
