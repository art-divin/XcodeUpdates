//
//  XcodeUpdatesEnvironment.swift
//  XcodeUpdates
//
//  Created by Ruslan Alikhamov on 26.11.2020.
//

import SwiftUI
import XcodeUpdatesInternal
import Combine

final class XcodeUpdatesEnvironment : ObservableObject, EnvironmentKey {
    
    static var defaultValue = XcodeUpdatesEnvironment()
    
    @Published var xcodeList : [XcodeVersion] = []
    @Published var downloadRequests : [XcodeUpdatesRequest] = []
    
    public lazy var notificationCentre : NotificationCentre = {
        NotificationCentre()
    }()
    
    private var installRequest : XcodeUpdatesRequest?
    
    public var isInstalling : Bool {
        return self.installRequest != nil
    }

    public private(set) var responseType : CurrentValueSubject<XcodeUpdatesResponseType, Never> = .init(.none)
    
    private var internals = XcodeUpdatesInternals()
    private var cancellables : [AnyCancellable] = []
    
    init() {
        self.setup()
    }
    
    public func downloadRequestFor(version: String) -> XcodeUpdatesRequest? {
        return self.downloadRequests.first { $0.isProcessing(version: version) }
    }
    
    public func installRequestFor(version: String) -> XcodeUpdatesRequest? {
        if let currentRequest = self.installRequest {
            return currentRequest.isProcessing(version: version) ? currentRequest : nil
        }
        return nil
    }
    
    private func fetchXcodeList() {
        self.xpcWrapper.fetchXcodeList(url: UserDefaults.standard.downloadsURL)
//        self.internals.reloadExec(RequestFactory.update(searchPath: UserDefaults.standard.downloadsURL))
    }
    
    lazy private var xpcWrapper : XPCWrapper = {
        XPCWrapper(sink: self.responseHandler)
    }()
    
    private func setupXPC() {
        self.xpcWrapper.fetchXcodeList(url: UserDefaults.standard.downloadsURL)
    }
    
    var responseHandler : (XcodeUpdatesResponse) -> Void {
        return {
            switch $0.type {
                case .list:
                    let list = ($0.list?.reversed() ?? [])
                        .map{ $0.content }
                        .map(XcodeVersion.init)
                    self.xcodeList = list
                default:
                    _ = 0 // we need to always send the response
            }
            self.responseType.send($0.type)
        }
    }
    
    private func setup() {
//        self.internals.output.sink { [self] in
//            switch $0.type {
//                case .list:
//                    let list = ($0.list?.reversed() ?? [])
//                        .map{ $0.content }
//                        .map(XcodeVersion.init)
//                    self.xcodeList = list
//                default:
//                    _ = 0 // we need to always send the response
//            }
//            self.responseType.send($0.type)
//        }.store(in: &self.cancellables)
//        self.fetchXcodeList()
        self.setupXPC()
    }
    
}

extension XcodeUpdatesEnvironment {
    
    func download(version: XcodeVersion, savedPath: URL?, statusOutput: PassthroughSubject<Result<Output, OutputError>, Never>) -> Result<XcodeUpdatesRequest, OutputError> {
        if self.isInstalling {
            return .failure(.anotherVersionIsBeingInstalled)
        }
        let request = RequestFactory.download(version: version.name, savedPath: savedPath)
        request.output = statusOutput
        self.internals.reloadExec(request)
        self.downloadRequests.append(request)
        request.isCancelled.sink(receiveValue: {
            if $0 {
                self.downloadRequests.removeAll { $0.id == request.id }
            }
        }).store(in: &self.cancellables)
        return .success(request)
    }
    
    func removeXip(version: XcodeVersion, savedPath: URL?, currentRequest: XcodeUpdatesRequest?, statusOutput: PassthroughSubject<Result<Output, OutputError>, Never>) -> Result<XcodeUpdatesRequest, OutputError> {
        if self.isInstalling {
            return .failure(.anotherVersionIsBeingInstalled)
        }
        currentRequest?.isCancelled.send(true)
        let request = RequestFactory.deleteXip(version: version.name, savedPath: savedPath)
        request.output = statusOutput
        self.internals.reloadExec(request)
        return .success(request)
    }
    
    // Login using the given login credentials
    func sendAuthRequest(challenge: Auth) {
        let inputAppleID = Input(input: challenge.appleID)
        let inputPassword = Input(input: challenge.password)
        self.xpcWrapper.authenticate(challenge: [inputAppleID, inputPassword])
    }
    
    func sendTwoFARequest(challenge: TwoFA) {
        let input2FA = Input(input: challenge.content)
//        let request = XcodeUpdatesRequest(input: [ input2FA ])
        self.xpcWrapper.sendTwoFA(challenge: [input2FA])
//        self.internals.input.send(request)
    }
    
    func sendPassword(challenge: Auth) {
        let inputPassword = Input(input: challenge.password)
        self.xpcWrapper.sendPassword(challenge: [inputPassword])
    }
    
    func install(version: String, statusOutput: PassthroughSubject<Result<Output, OutputError>, Never>) -> XcodeUpdatesRequest? {
        if let currentRequest = self.installRequest {
            if self.installRequestFor(version: version) == nil {
                statusOutput.send(.failure(.anotherVersionIsBeingInstalled))
                return nil
            }
            currentRequest.output = statusOutput
            return currentRequest
        }
        let url = UserDefaults.standard.downloadsURL
        let versionURL = url?.appendingPathComponent(version + ".xip")
        let unarchiveURL = UserDefaults.standard.unarchiveURL
        let request = RequestFactory.install(version: version, savedPath: versionURL, unarchiveURL: unarchiveURL)
        request.output = statusOutput
        request.isCancelled.sink(receiveValue: {
            if $0 {
                self.installRequest = nil
            }
        }).store(in: &self.cancellables)
        self.installRequest = request
        self.internals.reloadExec(request)
        return request
    }
    
    func reloadInternals() -> OutputError? {
        if self.isInstalling {
            return .anotherVersionIsBeingInstalled
        }
        self.xpcWrapper.fetchXcodeList(url: UserDefaults.standard.downloadsURL)
//        self.internals.reloadExec(RequestFactory.update(searchPath: UserDefaults.standard.downloadsURL))
        return nil
    }
    
    func unauthorize() -> OutputError? {
        if self.isInstalling {
            return .anotherVersionIsBeingInstalled
        }
        let request = RequestFactory.unauthorize()
        self.internals.reloadExec(request)
        return nil
    }
    
}

extension EnvironmentValues {
    
    var xcodeUpdatesEnvironment : XcodeUpdatesEnvironment {
        get {
            self[XcodeUpdatesEnvironment.self]
            
        }
        set {
            self[XcodeUpdatesEnvironment.self] = newValue
        }
    }
    
}
