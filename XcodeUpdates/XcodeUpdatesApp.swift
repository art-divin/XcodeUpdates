//
//  XcodeUpdatesApp.swift
//  XcodeUpdatesApp
//
//  Created by Ruslan Alikhamov on 15.11.2020.
//

import SwiftUI

@main
struct XcodeUpdatesApp : App {
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            XcodeUpdatesList()
        }
    }
    
}

