///
///  Service.swift
///  CyclOps
///
/// handles each device instance id (UUID), its bluetooth id (CBUUID),
/// and available services ([includedServices<CBService>], [CBCharacteristic])
///
/// see CBService [docs](https://developer.apple.com/documentation/corebluetooth/cbservice)
///
///  Created by Ron White on 6/5/24.
///
import CoreBluetooth

class Service: Identifiable {
    var id: UUID
    var uuid: CBUUID
    var service: CBService
    
    init(_uuid: CBUUID, _service: CBService) {
        id = UUID()
        uuid = _uuid
        service = _service
    }
}
