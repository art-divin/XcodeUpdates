//
//  Resources.swift
//  XcodeUpdates
//
//  Created by Ruslan Alikhamov on 19.11.2020.
//

import Foundation
import SwiftUI

enum ImageNames : String {
    case refresh
    case refresh_fill
}

extension Image {
    
    init(_ name: ImageNames) {
        self.init(nsImage: NSImage(named: name.rawValue)!)
    }
    
}

enum ColorNames : String {
    case blue
    case yellow
    case red
    case lighterRed
    case lightBlue
}

extension Color {

    init(name: ColorNames) {
        self.init(name.rawValue)
    }

}
