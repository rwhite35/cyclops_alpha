///
///  CyclOpsApp.swift
///  CyclOps
///
/// Apps root Scene which holds all content.
/// If global environmentals are required, add them here and
/// assign them to the Scene.environmentObject(ENV)
/// usage:
///   var auth = Auth()
///   ...
///   WindowGroup { ContentView( ).environmentObject(auth) }
///
/// Created by Ron White on 6/4/24.
///
import Foundation
import UIKit
import SwiftUI

@main
struct CyclOpsApp: App {
    
    /// AppDelegates adaptor
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    /// root view (Scene)
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
