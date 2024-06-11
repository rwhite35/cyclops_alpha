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
    @EnvironmentObject var cbModel: CBViewModel

    /// view properties
    let TAG = "DevicesView"
    @State var activeSheet: DevicesActiveSheet?
    
    // - MARK: main body view object
    var body: some View {
        ZStack {
            cbModel.navigationToDetailView(isDetailViewLinkActive:$cbModel.isConnected)
            
            GeometryReader { proxy in
                VStack {
                    if !cbModel.isSearching {
                        Button(action: {
                            if cbModel.isSearching { cbModel.stopScan() }
                            else { cbModel.startScan() }
                        }) {
                            cbModel.UIButtonView(
                                proxy: proxy,
                                text: cbModel.isSearching ? "Stop Scan" : "Start Scan"
                            )
                        }
                        Text(cbModel.isBlePower ? "" : "Check Settings, Bluetooth is Off!").padding(10)
                        List { PeripheralOptions() } /// each device found

                    } else { /// scan in progress, button to stop scan.
                        Color.gray.opacity(0.6).edgesIgnoringSafeArea(.all)
                        ZStack {
                            VStack { ProgressView() }
                            VStack {
                                Spacer()
                                Button(action: {
                                    cbModel.stopScan()
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
    
    /// Peripherals found as clickable button with connectPeripheral( ) action.
    /// only instantiates button for devices greater than -75 dBm strength.
    /// @see CBViewModel.didDiscover( ) for dBm limiter value
    /// @see CBPeripheralProtocol for avialable properties
    struct PeripheralOptions: View {
        @EnvironmentObject var cbModel: CBViewModel
        var body: some View {
            ForEach(0..<cbModel.foundPeripherals.count, id: \.self) { num in
                Button(action: {
                    cbModel.connectPeripheral(cbModel.foundPeripherals[num])
                    print(":\(#line) cbModel.foundPeripherals[\(num)] connectable: ")
                    /// print(cbModel.foundPeripherals[num].peripheral)
                }) {
                    HStack {
                        Text("\(cbModel.foundPeripherals[num].name)")
                        Spacer()
                        Text("\(cbModel.foundPeripherals[num].rssi) dBm")
                    }
                }
            }
        }
    }
}

/// ActiveSheets for this view stack
enum DevicesActiveSheet: Identifiable {
    case bledevice, camera
    var id: Int { hashValue }
}
