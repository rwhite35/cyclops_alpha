///
///  AppDelegate.swift
///  CyclOps
///
/// Unfortunately SwiftUI's support for push notifications requires UIApplications.AppDelegate
/// in order to support both remote Push notification and a local notification center.
/// Remote request a device token from Apple for APN notifications.
///
/// To that end, this will also be the main implementation class for app generated
/// UserNotifications as well as remote APN notifications.
///
///  Created by Ron White on 6/13/24.
///
import Foundation
import UIKit
import SwiftUI
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    
    let TAG = "AppDelegate"

    var notificationCenter: UNUserNotificationCenter?  // starts as a zeroing reference
    var notificationError: [Notification] = []
    var notificationStorage: [String: [String: [(String, Any) -> Void]]] = [:]
    var apnToken = ""
    
    /// runs before SwiftUI root view intialization.
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        /// request authorization for remote and system Push notifications
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, error in
            if granted {
                print("\(self.TAG).didFinishLaunching user granted NotificationCenter permission.")
                /** - uncomment once Apple APN Development is wired in
                DispatchQueue.main.async { UIApplication.shared.registerForRemoteNotifications() }
                 */
            }
        }
        return true
    }
    
    /// assigns appDelegate as object for UNUserNotificationCenter
    func application(_ application: UIApplication,
                     willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        notificationCenter = UNUserNotificationCenter.current()
        notificationCenter?.delegate = self
        print("\(self.TAG).willFinishLaunching sets appDelegate.notificationCeneter: \(notificationCenter)")
        print("\(self.TAG).willFinishLaunching resets notificationStorage: \(notificationStorage)")
        return true
    }
    
    // - MARK: NotificationCenter
    /**
     * registers app observers for system notification dispatch
     * observers defined in this block are notificied on named events.
     * NOT APN or Push notifications, see setupRemoteNotifications.
     */
    private func registerNotifications() {
        /// add Apple APN observers here, once wired in.
    }
    
    /// called on NotificationCenter granted permission
    // - TODO: send token to remote server once push notification has been implemented.
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
            /// convert for easy CentralNotificationCenter.notificationStorage
            let apnToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
            /// registerNotifications( ) /// add observers and store apnToken
            print("\(TAG).didRegisterFor APN token val: \(apnToken)")
    }
    
    /// automatically called on APN request fail.
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error) {
            print("Failed APN request with error: \(error)")
    }
    
    
    // - MARK: NotificationCenter Observer implementation
    //
    // adds observer for to the named notification and string message
    // NOTE: is a one to one relationship, there can be several notifications with the 
    //       same name but only one observer-notification combo is stored as an entry.
    // - Parameter:  _class is observer to add ie. `Camera` class
    // - Parameter: name is the notification name ie. `cameraState`
    // - Parameter: closure can be anything, but is mainly a string message ie. `Camera connected`
    ///
    func addObserver(_ _class: Any, name: String, closure: @escaping (String, Any) -> Void) {
        guard let observerClass = type(of: _class) as? AnyClass else {
            print("center.addObserver() :\(#line) cant handle type for class \(_class), returns here!")
            return
        }
        let className = String(describing: observerClass)
        if notificationStorage[className] != nil && notificationStorage[className]?[name] != nil {
            notificationStorage[className]?[name]?.append(closure)
        } else {
            notificationStorage[className] = [name:[closure]]
        }
        print("center.addObserver() :\(#line) added \(className) and notification name \(name)")
        print(" - notificationStorage value is \(notificationStorage)")
    }
    
    /// remove class observer-notification entry, by observers name
    func removeObserver(_ _class: Any) {
        guard let observerClass = type(of: _class) as? AnyClass else {
            print("center.removeObserver() :\(#line) cant handle type for class \(_class), returns here!")
            return
        }
        
        let className = String(describing: observerClass)
        guard notificationStorage[className] != nil else {
            print("center.removeObserver() :\(#line) didnt find notification for \(_class), returns here!")
            return
        }
        notificationStorage.removeValue(forKey: className)
    }
    
    /// post message to through NotificationCenter to all observers for a given named notification
    func postNotification(_ name: String, object: Any) {
        /// outter loop - each class
        for (_, notificationData) in notificationStorage {
            /// inner loop - notificationData tuple for this class
            for (notificationName, closure) in notificationData {
                guard notificationName == name else { continue }
                for closure in closure { closure(name, object) }
            }
        }
    }

}

// -MARK: local and remote delegate implementation
///
/// notifications name string
typealias NotificationObject = String
extension NotificationObject {
    func setNotificationObject(name: String) -> String { return name }
}

/// apps NotificationCenter typealias (listener)
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ){
        print("Notification posted with identifier \(notification.request.identifier)")
        print(notification)

        /// completionHandler displays the banner and plays notification sound, but only when app is in foreground
        completionHandler([.banner, .sound])
    }
}
