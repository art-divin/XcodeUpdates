//
//  PasswordDialog.swift
//  XcodeUpdates
//
//  Created by Ruslan Alikhamov on 04.01.2021.
//  Copyright © 2021 Ruslan Alikhamov. All rights reserved.
//

import SwiftUI

struct PasswordDialog: View {
    
    @Environment(\.presentationMode) var presentation
    @State var auth : Auth = Auth(password: "", appleID: "")
    var onDismiss : (Auth) -> Void
    
    var body: some View {
        VStack {
            SecureField("Apple ID Password", text: self.$auth.password)
                .padding(.top)
                .padding(.leading)
                .padding(.trailing)
            Text("Privacy note:")
                .font(.system(.footnote))
            Text("Your password is stored securely in macOS Keychain app.")
                .font(.system(.footnote))
            Text("It is transferred directly to developer.apple.com")
                .font(.system(.footnote))
            BlueButton(action: {
                self.presentation.wrappedValue.dismiss()
                self.onDismiss(self.auth)
            }, text: "Continue")
            .keyboardShortcut(.defaultAction)
            .padding(.top)
            .padding(.bottom, 10)
            .navigationTitle("Enter AppleID Password")
        }
        .frame(minWidth: 200, idealWidth: 300, maxWidth: 400, minHeight: 200, idealHeight: 200, maxHeight: 200, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }
}

struct PasswordDialog_Previews: PreviewProvider {
    static var previews: some View {
        PasswordDialog { _ in }
    }
}
