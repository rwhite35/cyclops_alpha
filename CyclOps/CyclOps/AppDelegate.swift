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
    
    /// Actionable Notification properties - for actual road training the data model
    /// - Accept action means the process correctly detected/notified on an approaching vehicle
    /// - Reject action means the process incorrectly notified rider that a vehicle was approaching.
    let acceptAction = UNNotificationAction(identifier: "ACCEPT_ACTION", title: "Accept", options: [])
    let rejectAction = UNNotificationAction(identifier: "REJECT_ACTION", title: "Reject", options: [])
    /// - Road training category differentiates from static or annotated training (ie Roboflow).
    /// other categories could be post ride if video was captured and stored.
    var roadTrainingCategory: UNNotificationCategory?
    let trainingIdentifier = "ROAD_TRAINING"
    
    /// Actionable Notification Payload
    let trial = UNMutableNotificationContent()

    /// Notification Center properties
    var notificationCenter: UNUserNotificationCenter?  // starts as a zeroing reference
    var notificationError: [Notification] = []
    var notificationStorage: [String: [String: [(String, Any) -> Void]]] = [:]
    var apnToken = ""
    
    /// runs before SwiftUI root view intialization.
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        /// request authorization for remote and system Push notifications
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]) { granted, error in

            if granted {
                print("\(self.TAG).didFinishLaunching user granted NotificationCenter permission.")
                /** - uncomment once Apple APN Development is wired in
                DispatchQueue.main.async { UIApplication.shared.registerForRemoteNotifications() }
                 */
            }
        }
        return true
    }
    
    /// assign AppDelegate UNUserNotificationCenter Center before startup completes to ensure
    /// any pending notification is handled
    func application(_ application: UIApplication,
                     willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        /// instantiate Actionable Notifications ROAD_TRAINING category
        roadTrainingCategory = UNNotificationCategory(
            identifier: trainingIdentifier,
            actions: [ acceptAction, rejectAction ],
            intentIdentifiers: [ ],
            hiddenPreviewsBodyPlaceholder: "",
            options: .customDismissAction)

        /// Actionable Notification payload
        trial.title = NSString.localizedUserNotificationString(forKey: "Vehicle Approaching!", arguments: nil)
        trial.body = NSString.localizedUserNotificationString(forKey: "Accept if correct", arguments: nil)
        trial.categoryIdentifier = trainingIdentifier

        notificationCenter = UNUserNotificationCenter.current()
        notificationCenter?.setNotificationCategories([roadTrainingCategory!])
        notificationCenter?.delegate = self
        
        print("\(self.TAG).willFinishLaunching sets appDelegate.notificationCeneter: \(String(describing: notificationCenter))")
        print("\(self.TAG).willFinishLaunching resets notificationStorage: \(notificationStorage)")
        
        /// trigger notification 2 minutes after launch
        /**
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2*60, repeats: false)
        let request = UNNotificationRequest(identifier: trainingIdentifier, content: trial, trigger: trigger)
        notificationCenter?.add(request) { error in
            if let error = error {
                print("error adding notification \(self.trainingIdentifier), with error \(error)")
            }
        }
        */

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
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
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

// -MARK: UNUserNotificationCenterDelegates
/// for local and remote notification protocol implementation
///
/// notifications name string
typealias NotificationObject = String
extension NotificationObject {
    func setNotificationObject(name: String) -> String { return name }
}

/// UNUserNotificationCenterDelegates protocol
///
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    /// Required, handles user’s response to a delivered notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                                didReceive response: UNNotificationResponse) async {
        print("Notification posted with identifier \(response.notification.description)")
        print(response)
    }

    /// Optional, handles notification arriving while app is running in foreground.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ){
        print("Notification posted with identifier \(notification.request.identifier)")
        print(notification)
        completionHandler([.banner, .sound])
    }
    
    /// Optional, display notification settings
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                                openSettingsFor notification: UNNotification?) {
        print("Opening Notification Settings \(String(describing: notification?.description))")
    }
}
