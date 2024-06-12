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
    @State var activeSheet: DetailsActiveSheet?

    /// view properties
    let TAG = "Devices"
    
    // - MARK: main body view object
    /// produces a list of connected bluetooth devices
    ///
    var body: some View {
        ZStack {
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
                        Text(cbModel.isBlePower ? "" : "Check Settings, Bluetooth is Off!")
                            .padding(10)
                        PeripheralOptions()

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
        .onChange(of: cbModel.showDeviceDetails) { value in
            if value { activeSheet = .deviceDetails }
            else { activeSheet = nil }
        }
        .onChange(of: cbModel.showHomeView) { value in
            if value { activeSheet = .homeView }
            else { activeSheet = nil }
        }
        .sheet(item: $activeSheet, onDismiss: {
            cbModel.showDeviceDetails = false
            cbModel.showHomeView = false
            cbModel.stopScan()
        }) { item in
            switch item {
            case .deviceDetails: DeviceDetails(deviceIdentifier: cbModel.getDeviceIdentifier())
            case .homeView: Home(model: HomeUI())
            }
        }
    }
    
    /// Peripherals found as clickable button with connectPeripheral( ) action.
    /// only instantiates button for devices greater than -75 dBm strength.
    /// @see CBViewModel.didDiscover( ) for dBm limiter value
    /// @see CBPeripheralProtocol for avialable properties
    struct PeripheralOptions: View {
        @EnvironmentObject var cbModel: CBViewModel
        @State var deviceIdentifier: DeviceIdentifier?

        var body: some View {
            NavigationStack {
                List(cbModel.foundPeripherals) { peripheral in
                    Button(action: {
                        cbModel.connectPeripheral(peripheral)
                        deviceIdentifier = cbModel.getDeviceIdentifier()
                    }) {
                        HStack {
                            Text("\(peripheral.name)")
                            Spacer()
                            Text("\(peripheral.rssi) dBm")
                        }
                    }
                }
            }
        }
    }
}

/// ActiveSheets for this view stack
enum DetailsActiveSheet: Identifiable {
    case deviceDetails, homeView
    var id: Int { hashValue }
}
