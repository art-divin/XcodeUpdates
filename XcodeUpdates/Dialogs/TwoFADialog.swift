//
//  2FADialog.swift
//  XcodeUpdates
//
//  Created by Ruslan Alikhamov on 20.11.2020.
//

import SwiftUI
import Combine

struct TwoFA {
    
    var content : String
    
}

struct TwoFADialog: View {
    
    @Environment(\.presentationMode) var presentation
    @State var input : TwoFA = TwoFA(content: "")
    var onDismiss : (TwoFA) -> Void
    
    var body: some View {
        VStack {
            TextField("2FA", text: self.$input.content)
                .padding(.leading)
                .padding(.trailing)
            Button(action: {
                self.onDismiss(self.input)
                self.presentation.wrappedValue.dismiss()
            }) {
                Text("Continue")
            }
            .keyboardShortcut(.defaultAction)
            .navigationTitle("Enter 2FA Code")
        }
        .frame(minWidth: 200, idealWidth: 300, maxWidth: 400, minHeight: 170, idealHeight: 170, maxHeight: 170, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }
    
}

#if DEBUG
struct TwoFADialog_Previews: PreviewProvider {
    static var previews: some View {
        TwoFADialog { _ in }
    }
}
#endif
