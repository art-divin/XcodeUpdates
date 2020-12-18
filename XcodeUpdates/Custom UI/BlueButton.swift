//
//  BlueButton.swift
//  XcodeUpdates
//
//  Created by Ruslan Alikhamov on 23.11.2020.
//

import SwiftUI

struct BlueButton: View {
    
    let action : () -> Void
    
    @State var text : String
    @State var backgroundColor : Color = .init(name: .lightBlue)
    @State var textColor : Color = .white
    
    enum Constants {
        static let buttonWidth : CGFloat = 100
        static let buttonHeight : CGFloat = 30
    }
    
    var body: some View {
        Button(action: {
            // TODO:
            self.action()
        }) {
            Text(self.text)
                .foregroundColor(self.textColor)
                .frame(width: Constants.buttonWidth, height: Constants.buttonHeight)
                .background(
                    RoundedRectangle(cornerRadius: 10.0)
                        .stroke(lineWidth: 0)
                        .background(self.backgroundColor)
                        .cornerRadius(10.0)
                        .frame(width: Constants.buttonWidth, height: Constants.buttonHeight, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                )
//                .padding(.init(top: 5, leading: 5, bottom: 5, trailing: 5))
                
        }
        .background(self.backgroundColor)
        .cornerRadius(10.0)
        .buttonStyle(PlainButtonStyle())
        .onHover(perform: { hovering in
            if hovering {
                self.backgroundColor = Color(name: .blue)
            } else {
                self.backgroundColor = Color(name: .lightBlue)
            }
        })
    }
}

#if DEBUG
struct BlueButton_Previews: PreviewProvider {
    static var previews: some View {
        BlueButton(action: {}, text: "Some text")
            .preferredColorScheme(.dark)
        BlueButton(action: {}, text: "Some text")
            .preferredColorScheme(.light)
    }
}
#endif
