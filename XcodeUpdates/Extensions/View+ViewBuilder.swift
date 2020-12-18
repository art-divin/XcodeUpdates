//
//  View+ViewBuilder.swift
//  XcodeUpdates
//
//  Created by Ruslan Alikhamov on 27.11.2020.
//

import SwiftUI

extension View {
    
    @ViewBuilder func hidden(_ visible: Binding<Bool>) -> some View {
        switch visible.wrappedValue {
        case true: self.hidden()
        case false: self
        }
    }
    
}
