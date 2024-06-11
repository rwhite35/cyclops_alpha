///
///  CBPeripheralProtocolDelegate.swift
///  CyclOps
///
///  the delegates, accessor methods and implementation code for
///  CBPeripheral and CBCentralManager APIs.
///
///  Created by Ron White on 6/5/24.
///
import Foundation
import CoreBluetooth

/// Peripherals
///
// - MARK: Peripheral interface delegates
protocol CBPeripheralProtocolDelegate {
    /// notified on discovery success
    func didDiscoverServices(_ peripheral: CBPeripheralProtocol, error: Error?)
    /// notified when characteristics were found
    func didDiscoverCharacteristics(_ peripheral: CBPeripheralProtocol, service: CBService, error: Error?)
    /// notified on characteristics updated
    func didUpdateValue(_ peripheral: CBPeripheralProtocol, characteristic: CBCharacteristic, error: Error?)
    /// notified on write to description success
    func didWriteValue(_ peripheral: CBPeripheralProtocol, descriptor: CBDescriptor, error: Error?)
}

// - MARK: Peripheral accessor methods
///
/// dependencies Devices.PeripheralOptions, CBViewModel.foundPeripherals[Peripheral],
/// called from CBCentralManager.scanForPeripherals( ) on found devices.
public protocol CBPeripheralProtocol {
    var delegate: CBPeripheralDelegate? { get set }
    
    var name: String? { get }
    var identifier: UUID { get } /// bridges to NSUUID
    var state: CBPeripheralState { get }
    var services: [CBService]? { get }
    var debugDescription: String { get }
    
    func discoverServices(_ serviceUUIDs: [CBUUID]?)
    func discoverCharacteristics(_ characteristicUUIDs: [CBUUID]?, for service: CBService)
    func discoverDescriptors(for characteristic: CBCharacteristic)
    func writeValue(_ data: Data, for characteristic: CBCharacteristic, type: CBCharacteristicWriteType)
    func readValue(for characteristic: CBCharacteristic)
    func setNotifyValue(_ enabled: Bool, for characteristic: CBCharacteristic)
}

// - MARK: Peripheral implementation code
extension CBPeripheral: CBPeripheralProtocol {}



// - MARK: Central Manager interface delegates
///
/// CBCentralManager and CBPeripheral delegates notified on action complete
public protocol CBCentralManagerProtocolDelegate {

    /// - central is instance of CBViewModel.centralManager, sent on Add Device scan
    func didUpdateState(_ central: CBCentralManagerProtocol)
    
    func willRestoreState(_ central: CBCentralManagerProtocol, 
                          dict: [String : Any])
    
    func didDiscover(_ central: CBCentralManagerProtocol,
                     peripheral: CBPeripheralProtocol,
                     advertisementData: [String : Any],
                     rssi: NSNumber)
    
    func didConnect(_ central: CBCentralManagerProtocol, 
                    peripheral: CBPeripheralProtocol)
 
    func didFailToConnect(_ central: CBCentralManagerProtocol,
                          peripheral: CBPeripheralProtocol, error: Error?)

    func didDisconnect(_ central: CBCentralManagerProtocol, 
                       peripheral: CBPeripheralProtocol, error: Error?)

    func connectionEventDidOccur(_ central: CBCentralManagerProtocol,
                                 event: CBConnectionEvent,
                                 peripheral: CBPeripheralProtocol)

    func didUpdateANCSAuthorization(_ central: CBCentralManagerProtocol,
                                    peripheral: CBPeripheralProtocol)
}

// - MARK: CBCentralManagerProtocol
///
/// interfaces methods for CBCentralManager implementation code
public protocol CBCentralManagerProtocol {
    /// objects with explicit accessor methods
    var delegate: CBCentralManagerDelegate? { get set }
    var state: CBManagerState { get }
    var isScanning: Bool { get }

    init(delegate: CBCentralManagerDelegate?, 
         queue: DispatchQueue?,
         options: [String : Any]?)

    /// called from wrapper method CBViewModel.startScan( ) on `Add Device` button action.
    /// depends on CBViewModel.foundPeripherals( ) to instantiate a button with connectPeripheral action.
    /// - note: CBViewModel passes nil for serviceUUIDs & AllowDuplicatesKey for options.
    func scanForPeripherals(
        withServices serviceUUIDs: [CBUUID]?,
        options: [String : Any]?)

    /// will notify delegate  didConnectPeripheral( )
    func connect(_ peripheral: CBPeripheralProtocol, options: [String : Any]?)

    func stopScan()
    func cancelPeripheralConnection(_ peripheral: CBPeripheralProtocol)
    func retrievePeripherals(_ identifiers: [UUID]) -> [CBPeripheralProtocol]
}


// - MARK: CBCentralManager
/// CBCentralManager implementation code for CBCentralManagerProtocol interface methods
extension CBCentralManager : CBCentralManagerProtocol {

    /// extended for CBViewModel.connectPeripheral( )
    /// connect device as a CBPeripheral object using CBCentralManagerProtocol
    public func connect(_ peripheral: CBPeripheralProtocol,
                        options: [String: Any]?
    ){
        print(":\(#line) CBCentralManager.connect( ) working...")
        let dname = peripheral.name ?? "NoName Device"

        guard let peripheral = peripheral as? CBPeripheral else {
            print(":WARN manager unable to cast \(dname) as CBPeripheral, returns here.")
            return
        }

        print(":\(#line) starting \(dname) discovery as CBPeripheral device!")
        connect(peripheral, options: options)
    }

    public func cancelPeripheralConnection(_ peripheral: CBPeripheralProtocol) {
        guard let peripheral = peripheral as? CBPeripheral else { return }
        cancelPeripheralConnection(peripheral)
    }

    public func retrievePeripherals(_ identifiers: [UUID]) -> [CBPeripheralProtocol] {
        return retrievePeripherals(withIdentifiers: identifiers)
    }
}
