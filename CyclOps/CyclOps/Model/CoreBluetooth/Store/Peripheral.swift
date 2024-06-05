///
///  Peripheral.swift
///  CyclOps
///
///  a remote peripheral device that has been discovered through CBCentralManager
///  Peripherals use universally unique identifiers (UUIDs), 
///  represented by NSUUID objects, to identify themselves.
///
///  see CBPeripheral [docs](https://developer.apple.com/documentation/corebluetooth/cbperipheral)
///
///  Created by Ron White on 6/5/24.
///
import CoreBluetooth

class Peripheral: Identifiable {
    var id: UUID
    var peripheral: CBPeripheralProtocol
    var name: String
    var advertisementData: [String : Any]
    var rssi: Int
    var discoverCount: Int
    
    init(_peripheral: CBPeripheralProtocol,
         _name: String,
         _advData: [String : Any],
         _rssi: NSNumber,
         _discoverCount: Int) {
        id = UUID()
        peripheral = _peripheral
        name = _name
        advertisementData = _advData
        rssi = _rssi.intValue
        discoverCount = _discoverCount + 1
    }
}
