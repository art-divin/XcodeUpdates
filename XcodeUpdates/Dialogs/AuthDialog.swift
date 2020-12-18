//
//  AuthDialog.swift
//  XcodeUpdates
//
//  Created by Ruslan Alikhamov on 20.11.2020.
//

import SwiftUI
import Combine

struct Auth : Identifiable, CustomDebugStringConvertible {
    
    var id: String {
        self.appleID
    }
    
    var debugDescription: String {
        "appleID: \(self.appleID.hash) password: \(self.password.hash)"
    }
    
    var password : String
    var appleID : String
    
}

struct AuthDialog: View {
    
    @Environment(\.presentationMode) var presentation
    @State var auth : Auth = Auth(password: "", appleID: "")
    var onDismiss : (Auth) -> Void
    
    var body: some View {
        VStack {
            TextField("Apple ID", text: self.$auth.appleID)
                .padding(.top)
                .padding(.leading)
                .padding(.trailing)
            SecureField("Password", text: self.$auth.password)
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
            .navigationTitle("Enter AppleID Credentials")
        }
        .frame(minWidth: 200, idealWidth: 300, maxWidth: 400, minHeight: 200, idealHeight: 200, maxHeight: 200, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }
}

#if DEBUG
struct AuthDialog_Previews: PreviewProvider {
    static var previews: some View {
        AuthDialog(auth: Auth(password: "", appleID: "")) { _ in }
    }
}
#endif
