//
//  SearchBar.swift
//  ToDoList
//
//  Created by Simon Ng on 15/4/2020.
//  Copyright © 2020 AppCoda. All rights reserved.
//

import SwiftUI
import AppKit

struct SearchBar: View {
    @Binding var text: String
    
    @State private var isNotEditing = true
    
    var body: some View {
        HStack {
            TextField("Search", text: $text)
                .padding(10)
                .padding(.horizontal, 25)
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        Button(action: {
                            self.text = ""
                        }) {
                            Image(systemName: "multiply.circle.fill")
                                .padding(.trailing, 0)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .clipShape(Circle())
                        .hidden(self.$isNotEditing)
                    }
                )
                .padding(.horizontal, 10)
//                .onTapGesture {
//                    self.isNotEditing = true
//                }
                .onChange(of: self.text, perform: { value in
                    self.isNotEditing = self.text.isEmpty
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(text: .constant(""))
    }
}
