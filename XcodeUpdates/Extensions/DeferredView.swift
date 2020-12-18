//
//  DeferredView.swift
//  XcodeUpdates
//
//  Created by Ruslan Alikhamov on 27.11.2020.
//  (c) https://stackoverflow.com/a/61242931/611055
//

import SwiftUI

struct DeferView<Content: View>: View {
    let content: () -> Content
    
    init(@ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
    }
    var body: some View {
        content()
    }
}
