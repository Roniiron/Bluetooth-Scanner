//
//  BLEManager.swift
//  Bluetooth Scanner
//
//  Created by Roni on 13. 10. 2025..
//

import Foundation
import CoreBluetooth

// MARK: - BLEManager
final class BLEManager: NSObject {
    // MARK: Properties
    private var centralManager: CBCentralManager!
    private var devices: [UUID: PeripheralModel] = [:]
    private var devicesStream: AsyncStream<[PeripheralModel]>.Continuation?
    
    private(set) var isScanning = false
    private(set) var bluetoothState: CBManagerState = .unknown
    private(set) var connectedDevice: PeripheralModel?
    
    // MARK: Continuations
    private var connectionContinuation: CheckedContinuation<Void, Error>?
    private var serviceDiscoveryContinuation: CheckedContinuation<[CBService], Error>?
    private var characteristicDiscoveryContinuation: CheckedContinuation<[CBCharacteristic], Error>?
    private var readValueContinuation: CheckedContinuation<Data?, Error>?
    private var writeValueContinuation: CheckedContinuation<Void, Error>?
    private var notificationContinuation: CheckedContinuation<Void, Error>?
    
    // MARK: Constants
    private enum Timeout {
        static let connection: TimeInterval = 10.0
        static let operation: TimeInterval = 5.0
    }
    
    // MARK: Lifecycle
    override init() {
        super.init()
        centralManager = CBCentralManager(
            delegate: self,
            queue: .main,
            options: [CBCentralManagerOptionShowPowerAlertKey: false]
        )
    }
    
    // MARK: Public API
    var discoveredDevices: AsyncStream<[PeripheralModel]> {
        AsyncStream { continuation in
            self.devicesStream = continuation
            continuation.yield(Array(devices.values))
        }
    }
    
    var isConnected: Bool {
        connectedDevice != nil
    }
}

// MARK: - BLEManagerProtocol
extension BLEManager: BLEManagerProtocol {
    func startScanning() async throws {
        try validateBluetoothState()
        guard !isScanning else { return }
        
        devices.removeAll()
        isScanning = true
        
        centralManager.scanForPeripherals(
            withServices: nil,
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: true]
        )
    }
    
    func stopScanning() async {
        guard isScanning else { return }
        
        centralManager.stopScan()
        isScanning = false
    }
    
    func connect(to device: PeripheralModel) async throws {
        try validateBluetoothState()
        guard connectedDevice == nil else { throw BLEError.invalidState }
        
        try await withTimeout(Timeout.connection) { continuation in
            self.connectionContinuation = continuation
            self.centralManager.connect(
                device.peripheral,
                options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey: true]
            )
        }
    }
    
    func disconnect() async {
        guard let device = connectedDevice else { return }
        
        centralManager.cancelPeripheralConnection(device.peripheral)
        connectedDevice = nil
    }
    
    func readAdvertisementData(for device: PeripheralModel) async throws -> [String: Any] {
        device.advertisementData
    }
    
    func discoverServices() async throws -> [CBService] {
        guard let device = connectedDevice else { throw BLEError.noConnectedDevice }
        
        return try await withTimeout(Timeout.operation) { continuation in
            self.serviceDiscoveryContinuation = continuation
            device.peripheral.discoverServices(nil)
        }
    }
    
    func discoverCharacteristics(for service: CBService) async throws -> [CBCharacteristic] {
        guard let device = connectedDevice else { throw BLEError.noConnectedDevice }
        
        return try await withTimeout(Timeout.operation) { continuation in
            self.characteristicDiscoveryContinuation = continuation
            device.peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func readValue(for characteristic: CBCharacteristic) async throws -> Data? {
        guard let device = connectedDevice else { throw BLEError.noConnectedDevice }
        
        return try await withTimeout(Timeout.operation) { continuation in
            self.readValueContinuation = continuation
            device.peripheral.readValue(for: characteristic)
        }
    }
    
    func writeValue(_ data: Data, for characteristic: CBCharacteristic, type: CBCharacteristicWriteType) async throws {
        guard let device = connectedDevice else { throw BLEError.noConnectedDevice }
        
        try await withTimeout(Timeout.operation) { continuation in
            self.writeValueContinuation = continuation
            device.peripheral.writeValue(data, for: characteristic, type: type)
        }
    }
    
    func setNotification(_ enabled: Bool, for characteristic: CBCharacteristic) async throws {
        guard let device = connectedDevice else { throw BLEError.noConnectedDevice }
        
        try await withTimeout(Timeout.operation) { continuation in
            self.notificationContinuation = continuation
            device.peripheral.setNotifyValue(enabled, for: characteristic)
        }
    }
    
    func clearDevices() async {
        devices.removeAll()
        devicesStream?.yield([])
    }
}

// MARK: - CBCentralManagerDelegate
extension BLEManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        bluetoothState = central.state
        
        if central.state != .poweredOn {
            isScanning = false
        }
    }
    
    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        let device = PeripheralModel(
            peripheral: peripheral,
            rssi: RSSI.intValue,
            advertisementData: advertisementData
        )
        
        devices[peripheral.identifier] = device
        devicesStream?.yield(Array(devices.values))
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectedDevice = devices[peripheral.identifier]
        peripheral.delegate = self
        
        connectionContinuation?.resume()
        connectionContinuation = nil
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        connectionContinuation?.resume(throwing: BLEError.connectionFailed(error ?? BLEError.unknown))
        connectionContinuation = nil
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectedDevice = nil
    }
}

// MARK: - CBPeripheralDelegate
extension BLEManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            serviceDiscoveryContinuation?.resume(throwing: BLEError.serviceDiscoveryFailed(error))
        } else {
            serviceDiscoveryContinuation?.resume(returning: peripheral.services ?? [])
        }
        serviceDiscoveryContinuation = nil
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            characteristicDiscoveryContinuation?.resume(throwing: BLEError.characteristicDiscoveryFailed(error))
        } else {
            characteristicDiscoveryContinuation?.resume(returning: service.characteristics ?? [])
        }
        characteristicDiscoveryContinuation = nil
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            readValueContinuation?.resume(throwing: BLEError.readValueFailed(error))
        } else {
            readValueContinuation?.resume(returning: characteristic.value)
        }
        readValueContinuation = nil
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            writeValueContinuation?.resume(throwing: BLEError.writeValueFailed(error))
        } else {
            writeValueContinuation?.resume()
        }
        writeValueContinuation = nil
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            notificationContinuation?.resume(throwing: BLEError.notificationFailed(error))
        } else {
            notificationContinuation?.resume()
        }
        notificationContinuation = nil
    }
}

// MARK: - Private Helpers
private extension BLEManager {
    func validateBluetoothState() throws {
        guard bluetoothState == .poweredOn else {
            throw BLEError.bluetoothUnavailable
        }
    }
    
    func withTimeout<T>(
        _ timeout: TimeInterval,
        operation: @escaping (CheckedContinuation<T, Error>) -> Void
    ) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            operation(continuation)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + timeout) { [weak self] in
                guard let self else {
                    return
                }
                
                // Check if continuation is still valid and cancel it
                continuation.resume(throwing: BLEError.timeout)
            }
        }
    }
}
