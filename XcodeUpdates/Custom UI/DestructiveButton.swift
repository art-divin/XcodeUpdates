//
//  DestructiveButton.swift
//  XcodeUpdates
//
//  Created by Ruslan Alikhamov on 22.11.2020.
//

import SwiftUI
import Combine

struct DestructiveButton: View {
    
    let action : () -> Void
    
    var imageName : String
    @State var deleteButtonColor : Color = .clear
    @State var deleteImageColor : Color = Color(name: .red)
    
    var body: some View {
        Button(action: {
            self.action()
        }) {
            VStack {
                Image(systemName: self.imageName)
                    .resizable()
                    .colorMultiply(self.deleteImageColor)
                    .frame(width: 25, height: 25, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            }
            .padding(.init(top: 5, leading: 5, bottom: 5, trailing: 5))
            .background(
                RoundedRectangle(cornerRadius: 10.0)
                    .stroke(lineWidth: 0)
                    .background(self.deleteButtonColor.cornerRadius(10.0))
            )
        }
        
        .accentColor(self.deleteButtonColor)
        .buttonStyle(PlainButtonStyle())
        .onHover(perform: { hovering in
            if hovering {
                self.deleteButtonColor = Color(name: .red)
                self.deleteImageColor = Color(name: .blue)
            } else {
                self.deleteButtonColor = .clear
                self.deleteImageColor = Color(name: .red)
            }
        })
    }
}

#if DEBUG
struct DestructiveButton_Previews: PreviewProvider {
    static var previews: some View {
        DestructiveButton(action: {}, imageName: "trash")
    }
}
#endif
