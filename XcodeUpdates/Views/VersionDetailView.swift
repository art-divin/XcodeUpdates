//
//  VersionDetailView.swift
//  XcodeUpdates
//
//  Created by Ruslan Alikhamov on 21.11.2020.
//

import SwiftUI
import Combine
import XcodeUpdatesInternal

enum VersionDetailAlert : Identifiable {
    case unfinished
    case error
    case installationOngoing
    case alreadyDownloaded
    case unableToCancelInstallation
    case installed
    case downloaded
    case removedXip
    case cannotRemoveXip

    var id : Int {
        self.hashValue
    }
    
}

struct VersionDetailView: View {
    
    @Environment(\.xcodeUpdatesEnvironment) var environment
    
    @State var version : XcodeVersion
    
    @State var cancellables : [AnyCancellable] = []
    @State var statusOutput : PassthroughSubject<Result<Output, OutputError>, Never> = .init()
    
    @State var alertPrompt : VersionDetailAlert?
    @State var status : String = ""
    var progress : Progress? {
        self.request?.progress
    }
    
    @State var isPaused : Bool = true
    @State var request : XcodeUpdatesRequest?
    
    var body: some View {
        VStack {
            Text("Version: \(self.version.name)")
                .padding(.top)
            Text("Release Date: \(self.version.releaseDateStr)")
                .padding(.leading)
                .padding(.trailing)
            Text(self.status)
                .hidden(self.$isPaused)
                .padding(.top)
                .padding(.bottom, 20)
            if let progress = self.progress {
                ProgressView(progress)
                    .padding(.leading)
                    .padding(.trailing)
                    .padding(.bottom)
            }
            VStack {
                if self.isPaused {
                    BlueButton(action: {
                        if !self.version.isDownloaded || self.version.isUnfinished {
                            self.downloadVersion()
                        } else {
                            self.alertPrompt = .alreadyDownloaded
                        }
                    }, text: "Download")
                    .padding(.bottom, 5)
                } else {
                    RedButton(action: {
                        self.stop()
                    }, text: "Stop")
                    .padding(.bottom, 5)
                }
                BlueButton(action: {
                    if self.version.isUnfinished || !self.version.isDownloaded {
                        self.alertPrompt = .unfinished
                    } else if self.version.isDownloaded {
                        self.install()
                    }
                }, text: "Install")
                .padding(.bottom, 5)
                BlueButton(action: {
                    // TODO: open in finder
                    guard let url = UserDefaults.standard.unarchiveURL else { return }
                    let config = NSWorkspace.OpenConfiguration()
                    config.promptsUserIfNeeded = true
                    NSWorkspace.shared.open(url, configuration: config)
                }, text: "Open in Finder")
                .padding(.bottom, 5)
                DestructiveButton(action: {
                    self.removeXip()
                }, imageName: "trash")
                .padding(.bottom)
            }
        }
        .alert(item: self.$alertPrompt) {
            var text : (Text, Text)
            switch $0 {
                case .unfinished:
                    text = (Text("Error"), Text("The download needs to be finished before this version can be installed"))
                case .error:
                    text = (Text("Error"), Text("An error occured. Please try again"))
                case .installationOngoing:
                    text = (Text("Error"), Text("There is an installation going on. Try again after it finishes or get cancelled"))
                case .alreadyDownloaded:
                    text = (Text("Info"), Text("This version is already downloaded"))
                case .unableToCancelInstallation:
                    text = (Text("Error"), Text("Underlying XIP command cannot be cancelled. Please wait until installation finishes"))
                case .installed:
                    text = (Text("Success"), Text("Xcode was successfully unarchived!"))
                case .downloaded:
                    text = (Text("Success"), Text("Xcode has been downloaded!"))
                case .removedXip:
                    text = (Text("Success!"), Text("Selected version of Xcode (xip, cache) was removed"))
                case .cannotRemoveXip:
                    text = (Text("Error"), Text("No downloaded files for this version were found"))
            }
            return Alert(title: text.0, message: text.1, dismissButton: .default(Text("Ok")))
        }
        .onAppear() {
            self.setup()
            if let request = self.environment.downloadRequestFor(version: self.version.name) {
                self.request = request
                self.request?.output = self.statusOutput
            } else if let request = self.environment.installRequestFor(version: self.version.name) {
                self.request = request
                self.request?.output = self.statusOutput
            }
        }
        .navigationTitle("Details")
    }
    
    private func setup() {
        if self.environment.isInstalling {
            return
        }
        self.statusOutput = .init()
        self.statusOutput.sink(receiveValue: {
            switch $0 {
                case .success(let output):
                    guard let status = output.latest else {
                        return
                    }
                    switch status.type {
                        case .status(let string):
                            if self.request != nil {
                                self.status = string
                                self.isPaused = false
                            }
                        case .downloaded(let string):
                            self.status = string
                            self.$version.wrappedValue.isUnfinished = false
                            self.$version.wrappedValue.isDownloaded = true
                            self.request?.isCancelled.send(true)
                            self.alertPrompt = .downloaded
                            self.stop()
                        case .removedXip:
                            self.alertPrompt = .removedXip
                        case .cannotRemoveXip:
                            self.alertPrompt = .cannotRemoveXip
                        case .installed:
                            self.$version.wrappedValue.isDownloaded = false
                            self.$version.wrappedValue.isInstalled = true
                            self.alertPrompt = .installed
                            let request = self.environment.installRequestFor(version: self.version.name)
                            request?.isCancelled.send(true)
                        default: return
                    }
                case .failure(_):
                    self.alertPrompt = .error
            }
        }).store(in: &self.cancellables)
        
    }
    
    private func install() {
        guard !self.environment.isInstalling else {
            self.alertPrompt = .installationOngoing
            return
        }
        self.setup()
        self.request = self.environment.install(version: self.version.name, statusOutput: self.statusOutput)
        self.request?.isCancelled.sink(receiveValue: {
            if $0 {
                self.cleanUp()
            }
        }).store(in: &self.cancellables)
        if self.request != nil {
            self.isPaused = false
        }
    }
    
    private func stop() {
        guard !self.environment.isInstalling else {
            self.alertPrompt = .unableToCancelInstallation
            return
        }
        self.request?.isCancelled.send(true)
        self.cleanUp()
    }
    
    private func cleanUp() {
        self.isPaused = true
        self.request = nil
    }
    
    private func removeXip() {
        self.setup()
        switch self.environment.removeXip(version: self.version, savedPath: UserDefaults.standard.downloadsURL, currentRequest: self.request, statusOutput: self.statusOutput) {
            case .success(_): return
            case .failure(_):
                self.alertPrompt = .installationOngoing
        }
    }
    
    private func downloadVersion() {
        self.setup()
        switch self.environment.download(version: self.version, savedPath: UserDefaults.standard.downloadsURL, statusOutput: self.statusOutput) {
            case .success(let request):
                self.request = request
                self.request?.output = self.statusOutput
            case .failure(_):
                self.alertPrompt = .installationOngoing
        }
        self.request?.isCancelled.sink(receiveValue: {
            if $0 {
                self.cleanUp()
            }
        }).store(in: &self.cancellables)
    }
    
}

#if DEBUG
struct VersionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        VersionDetailView(version: .init(name: "12.0 (2DFAD) (December 12, 2020)"))
            .preferredColorScheme(.dark)
        VersionDetailView(version: .init(name: "12.0 (2DFAD) (October 20, 2012)"))
            .preferredColorScheme(.light)
    }
}
#endif
