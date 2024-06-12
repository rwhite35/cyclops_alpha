//
//  CBViewModel.swift
//  CyclOps
//
//  Created by Ron White on 6/5/24.
//
import SwiftUI
import CoreBluetooth

class CBViewModel: NSObject, ObservableObject, CBPeripheralProtocolDelegate, CBCentralManagerProtocolDelegate {

    let TAG = "CBViewModel"
    @Published var isBlePower: Bool = false
    @Published var isSearching: Bool = false
    @Published var isConnected: Bool = false
    
    /// ActiveSheet triggers
    @Published var showDeviceDetails = false
    @Published var showDeviceList = false
    @Published var showHomeView = false

    /// all peripherals found in scan operation
    @Published var foundPeripherals: [Peripheral] = []
    @Published var foundServices: [Service] = []
    @Published var foundCharacteristics: [Characteristic] = []

    /// a peripheral selected from Devices List view
    private var centralManager: CBCentralManagerProtocol!
    private var connectedPeripheral: Peripheral!
    private var deviceIdentifier: DeviceIdentifier?

    /// this objects stable ID
    private let serviceUUID: CBUUID = CBUUID()

    override init() {
        super.init()
        #if targetEnvironment(simulator)
        centralManager = CBCentralManagerMock(delegate: self, queue: nil)
        #else
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
        #endif
    }
    

    // -MARK: CBCentralManager connect/disconnect methods
    ///
    /// resets device scan properties
    private func resetConfigure() {
        withAnimation {
            isSearching = false
            isConnected = false
            
            foundPeripherals = []
            foundServices = []
            foundCharacteristics = []
        }
    }

    /// wrapper method for CBCentralManager.scanForPeripherals( )
    /// - appends found CBPeripheral to CBCentralManager.foundPeripherals object
    func startScan() {
        print("CBViewModel.startScan() scanning for devices!")
        let scanOption = [
            CBCentralManagerScanOptionAllowDuplicatesKey: true,
        ]
        centralManager?.scanForPeripherals(
            withServices: nil,
            options: scanOption
        )
        isSearching = true
    }
    
    /// device button action method from startScan( ) -> scanForPeripherals( ) -> foundPeripherals[n]
    /// starts connection, auto calls CBCentralManager discovery for Services, Characteristics and Descriptors
    func connectPeripheral(_ selectedPeripheral: Peripheral?) {
        let dname = selectedPeripheral?.peripheral.name ?? "NoName Device"
        print(":\(#line) \(TAG).connectPeripheral working...")

        guard let connectPeripheral = selectedPeripheral else {
            print("WARN: \(TAG).connectPeripheral unable to connect \(dname), returns here.")
            return
        }
        /// assigns this device to CBViewModels Peripheral
        connectedPeripheral = selectedPeripheral

        /// wrapper for CBCentralManagerProtocol.connect( ), triggers device discovery methods
        centralManager.connect(connectPeripheral.peripheral, options: nil)
        
        /// convenience method for calling DeviceDetails( ) on navigation
        deviceIdentifier = saveDeviceIdentifier(selectedPeripheral!)
    }
    
    func saveDeviceIdentifier(_ selectedPeripheral: Peripheral) -> DeviceIdentifier {
        return DeviceIdentifier(
            name: selectedPeripheral.name,
            identifier: selectedPeripheral.peripheral.identifier,
            id: selectedPeripheral.id
        )
    }
    
    func getDeviceIdentifier() -> DeviceIdentifier { return self.deviceIdentifier! }
    
    /// wrapper method for CBCentralManager.stopScan( )
    /// - triggers resetConfiguration( ) from
    func stopScan(){
        print("CBViewModel.stopScan() scanning for devices!")
        disconnectPeripheral()
        centralManager?.stopScan()
        isSearching = false
        print(": Stopped scan")
    }
    
    /// wrapper method for CBCentralManager.cancelPeripheralConnection( )
    ///
    func disconnectPeripheral() {
        guard let connectedPeripheral = connectedPeripheral else { return }
        centralManager.cancelPeripheralConnection(connectedPeripheral.peripheral)
    }

    
    // -MARK: CBCentralManager delegates implementation
    /// methods in order of running process, from Add button through device selected.
    ///
    /// from startScan( ), notified on `Add Device` scan completion
    func didUpdateState(_ central: CBCentralManagerProtocol) {
        if central.state == .poweredOn { isBlePower = true }
        else { isBlePower = false }
        print(":\(#line) \(TAG).didUpdateState( ) notified...")
        /// print(": - centralManager.State.powerOn is \(isBlePower)!")
    }

    /// delegate notified on CBCentralManager.connect( ) :: CBPeripheralProtocol.connect( )
    /// depends on CBPeripheralProtocol.discoveryServices([CBUUID )
    func didConnect(_ central: CBCentralManagerProtocol,
                    peripheral: CBPeripheralProtocol
    ){
        let cpname = peripheral.name ?? "NoName Device"
        print(":\(#line) \(TAG).didConnect( ) notified...")
        
        guard let connectedPeripheral = connectedPeripheral else {
            print(":WARN \(TAG).didConnect can't assign \(cpname) to local, returns here.")
            return
        }
        /// self assigned as CBCentralManagerDelegate, notifies didDiscoverServices( )
        connectedPeripheral.peripheral.delegate = self
        connectedPeripheral.peripheral.discoverServices(nil)
        isConnected = true
        showDeviceDetails = isConnected
    }

    /// create a new device instance using CBCentralManagerProtocol as model
    /// appens found devices to self.foundPeripherals[Peripherals] indexed dict, starting with [0]
    /// - note: already called discovery methods defined in CBPeripheralProtocol
    func didDiscover(_ central: CBCentralManagerProtocol,
                     peripheral: CBPeripheralProtocol,
                     advertisementData: [String : Any],
                     rssi: NSNumber
    ){
        /// set a limiting range of greater than -74 dBm which is approx. a 10 ft radius of the phone
        if rssi.intValue <= -75 { return }
        
        /// print(":\(#line) \(TAG).didDiscover() notified...")
        let peripheralName = advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? nil

        let _name = (peripheralName != nil) ? String(peripheralName!) : (peripheral.name != nil)
                    ? String(peripheral.name!) : "NoName"
      
        let foundPeripheral: Peripheral = Peripheral(_peripheral: peripheral,
                                                     _name: _name,
                                                     _advData: advertisementData,
                                                     _rssi: rssi,
                                                     _discoverCount: 0)
        
        if let index = foundPeripherals.firstIndex(where: {
            $0.peripheral.identifier.uuidString == peripheral.identifier.uuidString
        }){
            if foundPeripherals[index].discoverCount % 50 == 0 {
                foundPeripherals[index].name = _name
                foundPeripherals[index].rssi = rssi.intValue
                foundPeripherals[index].discoverCount += 1
            } else {
                foundPeripherals[index].discoverCount += 1
            }
        } else {
            foundPeripherals.append(foundPeripheral)
            DispatchQueue.main.async { [self] in
                /// print("\(TAG).didDiscover() :\(#line) discovered \(foundPeripherals.count) devices in list.")
                self.isSearching = false
            }
        }
    }

    func didFailToConnect(_ central: CBCentralManagerProtocol, 
                          peripheral: CBPeripheralProtocol,
                          error: Error?
    ){
        disconnectPeripheral()
    }

    func didDisconnect(_ central: CBCentralManagerProtocol,
                       peripheral: CBPeripheralProtocol,
                       error: Error?
    ){
        print("disconnect")
        resetConfigure()
    }
    
    func connectionEventDidOccur(_ central: CBCentralManagerProtocol, 
                                 event: CBConnectionEvent,
                                 peripheral: CBPeripheralProtocol){}

    func willRestoreState(_ central: CBCentralManagerProtocol, dict: [String : Any]){}

    func didUpdateANCSAuthorization(_ central: CBCentralManagerProtocol, peripheral: CBPeripheralProtocol){}


    // -MARK: Peripheral delegates
    ///
    ///
    func didDiscoverServices(_ peripheral: CBPeripheralProtocol, error: Error?) {
        print(":\(#line) \(TAG).didDiscoverServices( ) notified...")
        if error != nil {
            print(":\(#line) - Error: \(String(describing: error))")
        } else {
            print(":\(#line) - CBPeripheralProtocol: \(peripheral)")
        }

        peripheral.services?.forEach { service in
            print(":\(#line) - found Service \(service)..., calls foundService.append( )!")
            let setService = Service(_uuid: service.uuid, _service: service)
            
            foundServices.append(setService)
            print(":\(#line) - next calls discoverCharacteristics( )")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func didDiscoverCharacteristics(_ peripheral: CBPeripheralProtocol, service: CBService, error: Error?) {
        print(":\(#line) \(TAG).didDiscoverCharacteristics( ) notified...")

        service.characteristics?.forEach { characteristic in
            print(":\(#line) - service.uuid \(service.uuid) characteristic:")
            print(characteristic)
            let setCharacteristic: Characteristic = Characteristic(_characteristic: characteristic,
                                                                   _description: "",
                                                                   _uuid: characteristic.uuid,
                                                                   _readValue: "",
                                                                   _service: characteristic.service!)
            foundCharacteristics.append(setCharacteristic)
            peripheral.readValue(for: characteristic)
        }
    }

    func didUpdateValue(_ peripheral: CBPeripheralProtocol, characteristic: CBCharacteristic, error: Error?) {
        guard let characteristicValue = characteristic.value else { return }
        
        if let index = foundCharacteristics.firstIndex(where: { $0.uuid.uuidString == characteristic.uuid.uuidString }) {
            
            foundCharacteristics[index].readValue = characteristicValue.map({ String(format:"%02x", $0) }).joined()
        }
    }

    func didWriteValue(_ peripheral: CBPeripheralProtocol, descriptor: CBDescriptor, error: Error?) {
        
    }
}

public protocol ConvenientIdentifier {
    var name: String? { get set }
    var identifier: UUID { get set }
}

struct DeviceIdentifier: ConvenientIdentifier, Identifiable, Hashable {
    var name: String?
    var identifier: UUID
    var id: ObjectIdentifier
}
