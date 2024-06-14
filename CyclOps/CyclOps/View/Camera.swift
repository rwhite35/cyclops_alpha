//
//  Camera.swift
//  CyclOps
//
//  Created by Ron White on 6/4/24.
//
import Foundation
import SwiftUI
import UserNotifications

struct Camera: View {
    let TAG = "Camera"
    @StateObject var model: CameraUI
    
    /// AVCaptureDevice implementation of UserNotifications.Center
    @State var isConnected: Bool = false

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello Camera!")
        }
        .padding()
        .onAppear {
            print("\(TAG).onAppear working...")
            model.addSelfCenterObserver()
        }
    }
}
