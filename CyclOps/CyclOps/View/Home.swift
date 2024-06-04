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
    @State var activeSheet: HomeActiveSheet?
    
    /// view nav components
    @ViewBuilder
    func homeAppBar() -> some View {
        ZStack {
            Rectangle().foregroundColor(Color.accentColor)
            HStack {
                /// Devices view
                Button(action: {
                    activeSheet = .devices
                }, label: {
                    Text("Add Device")
                }).foregroundColor(Color(UIColor.systemBackground))
                    .background(.ultraThinMaterial)
                    .frame(alignment: .leading)
                
                Spacer().frame(width:20)

                /// Camera view
                Button(action: {
                    activeSheet = .camera
                }, label: {
                    Text("Camera View")
                }).foregroundColor(Color(UIColor.systemBackground))
                    .background(.ultraThinMaterial)
                    .frame(alignment: .trailing)
            }.frame(maxWidth: .infinity)
        }.frame(height: 40)
    }
    
    /// main body object
    var body: some View {
        ZStack(alignment: .bottom, content: {
            Rectangle().foregroundColor(Color.blue).ignoresSafeArea(.container)
            VStack() {
                homeAppBar()
                Spacer()
            }
        })
        .onAppear {
            print(":\(#line) \(TAG) scenePhase is active!")
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
            case .devices: Devices()
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

/// view extensions
extension Text {
    /// Subheads, adapts to light/dark mode
    func sectionHeader() -> some View {
        font(Font.custom("Roboto",size:13)).fontWeight(.semibold).foregroundColor(.secondary)
    }
    /// Body Copy, adapts to light/dark mode
    func bodyCopy() -> some View {
        font(Font.custom("Roboto",size:12)).fontWeight(.regular).foregroundColor(Color(UIColor.systemGray))
    }
}
