//
//  XcodeUpdateRequestList.swift
//  XcodeUpdates
//
//  Created by Ruslan Alikhamov on 27.11.2020.
//

import SwiftUI
import XcodeUpdatesInternal

struct XcodeUpdateRequestList: View {
    
    @Environment(\.presentationMode) var presentation
    @Environment(\.xcodeUpdatesEnvironment) var environment
    
    @State var requests : [XcodeUpdatesRequest]
    @State var isListHidden = true
    
    var body: some View {
        VStack {
        List(self.requests) { item in
            HStack {
                ProgressView(item.progress)
                DestructiveButton(action: {
                    item.isCancelled.send(true)
                }, imageName: "xmark.circle.fill")
            }
        }
        .hidden(self.$isListHidden)
        .onReceive(self.environment.$downloadRequests) {
            self.requests = $0
            self.isListHidden = $0.isEmpty
        }
        if self.environment.downloadRequests.isEmpty {
            Text("No requests are currently being run")
                .padding()
        }
        BlueButton(action: {
            self.presentation.wrappedValue.dismiss()
        }, text: "Close")
        }
        .frame(width: 300, height: self.isListHidden ? 100 : 300)
        .padding()
    }
    
}

struct XcodeUpdateRequestList_Previews: PreviewProvider {
    
    static func list(_ colorScheme: ColorScheme) -> some View {
        let requests = [
            XcodeUpdatesRequest(input: [Input(args: ["update"], input: nil)]),
            XcodeUpdatesRequest(input: [Input(args: ["update"], input: nil)]),
            XcodeUpdatesRequest(input: [Input(args: ["update"], input: nil)])
        ]
        requests.forEach {
            $0.progress.totalUnitCount = 10_000_000
            $0.progress.completedUnitCount = Int64.random(in: 0 ... 10_000_000)
        }
        let list = XcodeUpdateRequestList(requests: requests)
        return list
            .preferredColorScheme(colorScheme)
    }
    
    static var previews: some View {
        list(.dark)
        list(.light)
    }
    
}
