//
//  LocalNotification.swift
//  XcodeUpdates
//
//  Created by Ruslan Alikhamov on 31.12.2020.
//  Copyright © 2020 Ruslan Alikhamov. All rights reserved.
//

import Foundation
import UserNotifications
import XcodeUpdatesInternal

struct NotificationCentre {
    
    private var shared : UNUserNotificationCenter {
        UNUserNotificationCenter.current()
    }
    
    private enum Constants {
        static let newVersionIdentifier = "com.xcodeupdates.app.XcodeUpdates.newVersion"
    }
    
    public func notify(version: XcodeVersion) {
        self.authorize {
            self.notifyUser()
        }
    }
    
    private func authorize(_ completion: @escaping () -> Void) {
        self.shared.requestAuthorization(options: [.sound, .alert]) {
            if let error = $1 {
                print("error requesting permissions: \(error)")
            } else if $0 {
                completion()
            }
        }
    }
    
    private func notifyUser() {
        let content = UNMutableNotificationContent()
        content.body = "New Xcode version became available!"
        let notification = UNNotificationRequest(identifier: Constants.newVersionIdentifier, content: content, trigger: nil)
        self.shared.add(notification) { (error) in
            print("error adding notification: \(String(describing: error))")
        }
    }
    
}
