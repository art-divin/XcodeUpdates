//
//  XcodeUpdatesList.swift
//  XcodeUpdates
//
//  Created by Ruslan Alikhamov on 19.11.2020.
//

import XcodeUpdatesInternal
import Combine
import SwiftUI

enum XcodeUpdateListSheet : Identifiable {
    case auth
    case twoFA
    case settings
    case downloads
    
    var id : Int {
        self.hashValue
    }
    
}

enum XcodeUpdateListAlert : Identifiable {
    
    case error
    case installationOngoing
    case unauthorized
    case logout
    
    var id : Int {
        self.hashValue
    }
    
}

struct XcodeUpdatesList: View {
    
    @Environment(\.xcodeUpdatesEnvironment) var environment
    
    @State private var cancellables : [AnyCancellable] = []
    @State private var sheetPrompt : XcodeUpdateListSheet?
    @State private var alertPrompt : XcodeUpdateListAlert?
    @State private var xcodeList : [XcodeVersion] = []
    
    @State private var searchText : String = ""
    @State private var windowWidth = Constants.windowWidth
    
    @State private var hasActiveRequests : Bool = false
    @State private var selectedVersion : XcodeVersion?
    
    enum Constants {
        static let checkmarkCellWidth : CGFloat = 80
        static let listWidth : CGFloat = 700
        static let windowHeight : CGFloat = 700
        static let expandedWindowWidth : CGFloat = 1000
        static let windowWidth : CGFloat = 700
        static let listHeight : CGFloat = 650
        static let releaseDateWidth : CGFloat = 160
    }
    
    var body: some View {
        HSplitView() {
            NavigationView {
                VStack {
                    HStack {
                        Text("Version")
                            .font(.callout)
                            .frame(width: 230)
                        Divider()
                        Text("Release Date")
                            .font(.callout)
                            .frame(width: Constants.releaseDateWidth)
                        Divider()
                        Text("Downloaded")
                            .font(.callout)
                            .frame(width: Constants.checkmarkCellWidth)
                        Divider()
                        Text("Installed")
                            .font(.callout)
                            .frame(width: Constants.checkmarkCellWidth)
                        Divider()
                        Text("Selected")
                            .font(.callout)
                            .frame(width: Constants.checkmarkCellWidth)
                    }
                    .frame(width: Constants.listWidth, height: 20)
                    List(self.xcodeList.filter { self.searchText.isEmpty ? true : $0.name.contains(self.searchText) }) { xcodeVersion in
                        NavigationLink(destination: DeferView {
                            self.select(version: xcodeVersion)
                        }) {
                            Text(xcodeVersion.name)
                                .frame(width: 215, height: 30, alignment: .center)
                            Divider()
                            Text(xcodeVersion.releaseDateStr)
                                .frame(width: Constants.releaseDateWidth, height: 30, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            Divider()
                            self.checkmark(xcodeVersion.isDownloaded, color: xcodeVersion.isUnfinished ? Color(name: .yellow) : nil)
                                .frame(width: Constants.checkmarkCellWidth)
                            Divider()
                            self.checkmark(xcodeVersion.isInstalled)
                                .frame(width: Constants.checkmarkCellWidth)
                            Divider()
                            self.checkmark(xcodeVersion.isSelected)
                                .frame(width: Constants.checkmarkCellWidth)
                        }
                    }
                }
                .frame(width: Constants.listWidth, height: Constants.listHeight, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            }
        }
        .frame(minWidth: self.windowWidth, idealWidth: self.windowWidth, maxWidth: self.windowWidth, minHeight: Constants.windowHeight, idealHeight: Constants.windowHeight, maxHeight: Constants.windowHeight, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                SearchBar(text: self.$searchText)
                    .frame(width: 200, height: 30, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            }
            ToolbarItem(placement: .status) {
                Button(action: {
                    self.alertPrompt = .logout
                }) {
                    Image(systemName: "person.crop.circle")
                }
                .clipShape(Circle())
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(action: {
                    self.reloadVersionList()
                }) {
                    Image(systemName: "arrow.clockwise.circle")
                }
                .clipShape(Circle())
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(action: {
                    self.sheetPrompt = .settings
                }) {
                    Image(systemName: "gear")
                }
                .clipShape(Circle())
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(action: {
                    self.sheetPrompt = .downloads
                }) {
                    VStack {
                        Image(systemName: "list.dash")
                            .padding(.bottom, self.hasActiveRequests ? -10 : 0)
                        if self.hasActiveRequests {
                        ProgressView()
                            .progressViewStyle(LinearProgressViewStyle())
                            .padding(.bottom, -10)
                        }
                    }
                }
                .clipShape(Circle())
            }
        }
        .sheet(item: self.$sheetPrompt) {
            switch $0 {
                case .auth:
                    AuthDialog {
                        self.environment.sendAuthRequest(challenge: $0)
                    }
                case .twoFA:
                    TwoFADialog {
                        self.environment.sendTwoFARequest(challenge: $0)
                    }
                case .settings:
                    Preferences()
                case .downloads:
                    XcodeUpdateRequestList(requests: [])
            }
        }
        .alert(item: self.$alertPrompt) {
            var text : (Text, Text)
            switch $0 {
                case .error:
                    text = (Text("Error"), Text("An error occured. Please try again"))
                case .installationOngoing:
                    text = (Text("Error"), Text("There is an installation going on. Try again after it finishes or get cancelled"))
                case .unauthorized:
                    text = (Text("Success"), Text("Stored credentials have been removed from Keychain"))
                case .logout:
                    text = (Text("Warning"), Text("Stored credentials will be removed"))
                    return Alert(title: text.0, message: text.1, primaryButton: .destructive(Text("Remove")) { self.unauthorize() }, secondaryButton: .cancel(Text("Cancel")))
            }
            return Alert(title: text.0, message: text.1, dismissButton: .default(Text("Ok")))
        }
        .onAppear {
            self.setup()
        }
    }
    
    private func select(version: XcodeVersion) -> some View {
        self.selectedVersion = version
        self.windowWidth = Constants.expandedWindowWidth
        return VersionDetailView(version: version)
                .navigationTitle("Version")
    }
    
    private func checkmark(_ value: Bool, color: Color? = nil) -> some View {
        if value {
            return Image(systemName: "checkmark.circle.fill")
                .colorMultiply(color ?? Color(name: .blue))
                .frame(width: 25, height: 25, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        } else {
            return Image(systemName: "checkmark.circle")
                .colorMultiply(Color(name: .lightBlue))
                .frame(width: 25, height: 25, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        }
    }
    
    private func setup() {
        self.environment.$xcodeList.sink {
            self.xcodeList = $0
        }.store(in: &self.cancellables)
        self.environment.responseType.sink {
            switch $0 {
                case .auth:
                    self.sheetPrompt = .auth
                case .twoFA:
                    self.sheetPrompt = .twoFA
                case .unauthorized:
                    self.alertPrompt = .unauthorized
                case .error:
                    self.alertPrompt = .error
                default: return
            }
        }.store(in: &self.cancellables)
        self.environment.$downloadRequests.sink {
            self.hasActiveRequests = !$0.isEmpty
        }.store(in: &self.cancellables)
    }
    
    private func unauthorize() {
        if let _ = self.environment.unauthorize() {
            self.alertPrompt = .installationOngoing
        }
    }
    
    private func reloadVersionList() {
        if let _ = self.environment.reloadInternals() {
            self.alertPrompt = .installationOngoing
        }
    }
    
}

#if DEBUG
struct XcodeUpdatesList_Previews: PreviewProvider {
    static var previews: some View {
        XcodeUpdatesList()
            .preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)
        XcodeUpdatesList()
            .preferredColorScheme(.light)
    }
}
#endif
