//
//  Home.swift
//  CyclOps
//
//  Created by Ron White on 6/4/24.
//

import SwiftUI

struct Home: View {
    
    /// view properties
    let TAG = "HomeView"
    @StateObject var model: HomeUI
    @State var screenSize: CGSize = .zero
    @State var activeSheet: HomeActiveSheet?
    @State var detectMng = DetectionManager()
    @State var odsLblPrefix: String?

    /// modal presentation sheet nav
    /// - Devices: add a bluetooth camera(s)
    /// - Camera: list of paired camera options
    @ViewBuilder
    func homeAppBar() -> some View {
        ZStack {
            Rectangle().foregroundColor(Color.accentColor)
            HStack {
                /// Devices view
                Button(action: {
                    activeSheet = .devices
                }, label: {
                    Text("Add Camera").mainBtnLabel()
                }).buttonStyle(NavButton()).frame(alignment: .leading)
                ///
                Spacer().frame(width:20)
                /// Camera view
                Button(action: {
                    activeSheet = .camera
                }, label: {
                    Text("Saved Cameras").mainBtnLabel()
                }).buttonStyle(NavButton()).frame(alignment: .trailing)
            }.frame(maxWidth: .infinity)
        }.frame(height:40)
    }
    
    /// control element for starting and stopping an Object Detection (OD) Session
    /// - Start ODSession: start a new ODSession and AVSession
    /// - Stop ODSession: stops an existing ODSession
    @ViewBuilder
    func odsStartStop(manager: DetectionManager) -> some View {
        let prefix = manager.isODSRunning ? manager.odsLabel[1] : manager.odsLabel[0]
        HStack(spacing: 20){
            Button(action: { 
                /// will start a new Object Detection Session
                print(":\(#line) \(TAG) - odsStartStop tapped, \(prefix)'s ODSession!")
            }, label: {
                Text("\(prefix) Detection").mainBtnLabel()
            }).buttonStyle(MainButton())
        }.frame(maxWidth: .infinity)
    }
    
    // - MARK: main body view object
    ///
    var body: some View {
        ZStack(alignment: .top, content: {
            Rectangle().foregroundColor(Color("viewBkg")).saveSize(in: $screenSize)
            VStack(
                alignment: .center,
                spacing: 20
            ){
                homeAppBar()
                Text("Hello Safe Cyclist!")
                Spacer()
                let addCam = Text("Add Camera").italic()
                let savCam = Text("Save Cameras").italic()
                Text("Tap \(addCam) to pair a new bluetooth enabled camera,\nor \(savCam) to select a different camera in your camera inventory.\n\nTap Start button to begin object detection using a connected and active camera.")
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: screenSize.width / 1.328, maxHeight: screenSize.height / 4)
                Spacer()
                odsStartStop(manager: detectMng)
                Spacer()

                GeometryReader { proxy in
                    HStack {}.onAppear { screenSize = proxy.size }
                }
            }
        })
        .onAppear {
            model.scenePhase = .active
            print(":\(#line) \(TAG) scenePhase is active! screen width \(screenSize.width), height \(screenSize.height).")
            odsLblPrefix = (detectMng.isODSRunning) ? detectMng.odsLabel[1] : detectMng.odsLabel[0]
        }
        .onChange(of: model.showDevices) { value in
            if value { activeSheet = .devices }
            else { activeSheet = nil }
        }
        .onChange(of: model.showCamera) { value in
            if value { activeSheet = .camera }
            else { activeSheet = nil }
        }
        /// replace home content
        .sheet(item: $activeSheet, onDismiss: {
            model.showDevices = false
            model.showCamera = false
        }) { item in
            switch item {
            case .devices: Devices().environmentObject(CBViewModel())
            case .camera: Camera()
            }
        }
    }
}

/// ActiveSheets for this view stack
enum HomeActiveSheet: Identifiable {
    case devices, camera
    var id: Int { hashValue }
}
