//
//  Characteristic.swift
//  CyclOps
//
//  Created by Ron White on 6/5/24.
//
import CoreBluetooth

class Characteristic: Identifiable {
    var id: UUID
    var characteristic: CBCharacteristic
    var description: String
    var uuid: CBUUID
    var readValue: String
    var service: CBService
    var notProvided = "Not Provided"

    init(_characteristic: CBCharacteristic,
         _description: String,
         _uuid: CBUUID,
         _readValue: String,
         _service: CBService) {
        
        id = UUID()
        characteristic = _characteristic
        description = !_description.isEmpty ? _description : notProvided
        uuid = _uuid
        readValue = !_readValue.isEmpty ? _readValue : notProvided
        service = _service
    }
}

