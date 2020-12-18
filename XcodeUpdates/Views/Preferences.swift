//
//  Preferences.swift
//  XcodeUpdates
//
//  Created by Ruslan Alikhamov on 27.11.2020.
//

import SwiftUI

struct Preferences: View {
    
    @Environment(\.presentationMode) var presentation
    
    enum Constants {
        static let windowWidth : CGFloat = 400
        static let windowHeight : CGFloat = 200
    }
    
    var body: some View {
        VStack {
            let preferences = Preferences_AppKit()
            preferences
                .frame(width: Constants.windowWidth, height: Constants.windowHeight, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            BlueButton(action: {
                if let paths = preferences.saveAction.value?() {
                    UserDefaults.standard.unarchiveURL = paths.unarchivePath
                    UserDefaults.standard.downloadsURL = paths.downloadsPath
                }
                self.presentation.wrappedValue.dismiss()
            }, text: "Save")
            .padding(.bottom, 50)
        }
    }
    
}

#if DEBUG
struct Preferences_Previews: PreviewProvider {
    static var previews: some View {
        Preferences()
    }
}
#endif
