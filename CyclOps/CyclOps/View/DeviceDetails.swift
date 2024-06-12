//
//  DeviceDetails.swift
//  CyclOps
//
//  Created by Ron White on 6/11/24.
//

import SwiftUI

struct DeviceDetails: View {
    @EnvironmentObject var cbModel: CBViewModel
    @State var deviceIdentifier: DeviceIdentifier
    let TAG = "DeviceDetails"

    var body: some View {
        let _ = print(":\(#line) \(TAG).View rendering...")
        GeometryReader { proxy in
            VStack {
                Button(action: {
                    cbModel.disconnectPeripheral()
                    cbModel.stopScan()
                }) {
                    cbModel.UIButtonView(proxy: proxy, text: "Disconnect")
                }
                Text(cbModel.isBlePower ? "" : "Device bluetooth is out-of-range or off!").padding(10)
                List {
                    CharacteriticCells()
                }
                .navigationBarTitle("Available Device")
                .navigationBarBackButtonHidden(true)
            }
        }
    }
    
    struct CharacteriticCells: View {
        @EnvironmentObject var cbModel: CBViewModel
        var body: some View {
            ForEach(0..<cbModel.foundServices.count, id: \.self) { idx in
                Section(header: Text("\(cbModel.foundServices[idx].uuid.uuidString)")) {
                    ForEach(0..<cbModel.foundCharacteristics.count, id: \.self) { j in
                        if cbModel.foundServices[idx].uuid == cbModel.foundCharacteristics[j].service.uuid {
                            Button(action: {
                                print(":\(#line) CharacteristicCells Button for service.uuid \(cbModel.foundCharacteristics[j].service.uuid)")
                            }) {
                                VStack {
                                    HStack {
                                        Text("uuid: \(cbModel.foundCharacteristics[j].uuid.uuidString)")
                                            .font(.system(size: 14))
                                            .padding(.bottom, 2)
                                        Spacer()
                                    }
                                    HStack {
                                        Text("description: \(cbModel.foundCharacteristics[j].description)")
                                            .font(.system(size: 14))
                                            .padding(.bottom, 2)
                                        Spacer()
                                    }
                                    HStack {
                                        Text("value: \(cbModel.foundCharacteristics[j].readValue)")
                                            .font(.system(size: 14))
                                            .padding(.bottom, 2)
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
