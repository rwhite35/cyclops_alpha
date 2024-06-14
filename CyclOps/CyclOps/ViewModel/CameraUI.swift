//
//  CameraUI.swift
//  CyclOps
//
//  Created by Ron White on 6/4/24.
//

import Foundation
import SwiftUI

class CameraUI: NSObject, ObservableObject {
    @Published var isConnected = false
    @Published var cameraLive = false
    @Published var cameraReady = false
    
    /// NotificationCenter
    @Published var notificationName = "Camera"
    @Published var notificationMess = ""
    let nameAdjectives: [String] = [" disconnected", " connected", " unknown status"]
    func getNotificationName(adj: Int) -> String {
        return (adj < nameAdjectives.count) ? notificationName + nameAdjectives[adj] : notificationName + nameAdjectives.last!
    }
    func addSelfCenterObserver() {
        print("CameraUI.addSelfCenterObserver as listener for \(notificationName)")
        let center = AppDelegate()
        center.addObserver(self, name: notificationName) { (name, object) in
            let message = name + self.getNotificationName(adj: 2)
            print(message)
        }
    }
}
