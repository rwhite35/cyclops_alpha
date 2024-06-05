///
///  Devices.swift
///  CyclOps
///
///  scans for bluetooth devices and outputs them in a list if found
///  and able to connect.
///
///  Created by Ron White on 6/4/24.
///
import SwiftUI

struct Devices: View {
    @EnvironmentObject var cbManager: CBViewModel

    var body: some View {
        ZStack {
            cbManager.navigationToDetailView(isDetailViewLinkActive:$cbManager.isConnected)
            
            GeometryReader { proxy in
                VStack {
                    if !cbManager.isSearching {
                        Button(action: {
                            if cbManager.isSearching { cbManager.stopScan() }
                            else { cbManager.startScan() }
                        }) {
                            cbManager.UIButtonView(
                                proxy: proxy,
                                text: cbManager.isSearching ? "Stop Scan" : "Start Scan")
                        }
                        Text(cbManager.isBlePower ? "" : "Bluetooth Setting Off").padding(10)
                        List { PeripheralOptions() }

                    } else { /// first stack
                        Color.gray.opacity(0.6).edgesIgnoringSafeArea(.all)
                        ZStack {
                            VStack { ProgressView() }
                            VStack {
                                Spacer()
                                Button(action: {
                                    cbManager.stopScan()
                                }) {
                                    Text("Stop Scanning").padding()
                                }
                            }
                        }
                        .frame(width: proxy.size.width / 2,
                               height: proxy.size.width / 2,
                               alignment: .center)
                        .background(Color.gray.opacity(0.5))
                    }
                }
            }
        }
    }
    
    /// nested option list of found peripherals
    ///
    struct PeripheralOptions: View {
        @EnvironmentObject var cbManager: CBViewModel
        var body: some View {
            ForEach(0..<cbManager.foundPeripherals.count, id: \.self) { num in
                Button(action: {
                    cbManager.connectPeripheral(cbManager.foundPeripherals[num])
                }) {
                    HStack {
                        Text("\(cbManager.foundPeripherals[num].name)")
                        Spacer()
                        Text("\(cbManager.foundPeripherals[num].rssi) dBm")
                    }
                }
            }
        }
    }
}
