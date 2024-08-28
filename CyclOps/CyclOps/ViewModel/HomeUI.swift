//
//  HomeUI.swift
//  CyclOps
//
//  Created by Ron White on 6/4/24.
//
import Foundation
import SwiftUI

class HomeUI: NSObject, ObservableObject {
    @Published var scenePhase: ScenePhase?
    @Published var orientation = UIDevice.current.orientation
    @Published var showHome = false
    @Published var showDevices = false
    @Published var showCamera = false
    @Published var showPermissions = false
}
