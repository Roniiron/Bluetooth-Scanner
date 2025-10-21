//
//  BLEManager.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import Foundation
import CoreBluetooth

/// Main manager that manages BLE operations by delegating to specialized services
/// Implements the full BLEManagerProtocol by composing services
///
/// This is an ObservableObject that should be injected via EnvironmentObject
/// at the app root level to ensure single instance throughout the app lifecycle.
final class BLEManager: NSObject, ObservableObject {
    // MARK: - Properties
    private var centralManager: CBCentralManager!
    private var scanningService: BLEScanningServiceProtocol!
    private var connectionService: BLEConnectionServiceProtocol!
    private var serviceExplorer: BLEServiceExplorerProtocol!
    private var notificationService: BLENotificationServiceProtocol!
    
    private(set) var bluetoothState: CBManagerState = .unknown
    private var devices: [UUID: PeripheralModel] = [:]
    
    // MARK: - Lifecycle
    override init() {
        super.init()
        let central = CBCentralManager(
            delegate: self,
            queue: .main,
            options: [CBCentralManagerOptionShowPowerAlertKey: false]
        )
        let connection = BLEConnectionService(centralManager: central)
        self.configure(
            centralManager: central,
            scanningService: BLEScanningService(centralManager: central),
            connectionService: connection,
            serviceExplorer: BLEServiceExplorer(connectionService: connection),
            notificationService: BLENotificationService(connectionService: connection)
        )
    }

    init(
        centralManager: CBCentralManager,
        scanningService: BLEScanningServiceProtocol,
        connectionService: BLEConnectionServiceProtocol,
        serviceExplorer: BLEServiceExplorerProtocol,
        notificationService: BLENotificationServiceProtocol
    ) {
        super.init()
        self.configure(
            centralManager: centralManager,
            scanningService: scanningService,
            connectionService: connectionService,
            serviceExplorer: serviceExplorer,
            notificationService: notificationService
        )
    }

    private func configure(
        centralManager: CBCentralManager,
        scanningService: BLEScanningServiceProtocol,
        connectionService: BLEConnectionServiceProtocol,
        serviceExplorer: BLEServiceExplorerProtocol,
        notificationService: BLENotificationServiceProtocol
    ) {
        self.centralManager = centralManager
        self.scanningService = scanningService
        self.connectionService = connectionService
        self.serviceExplorer = serviceExplorer
        self.notificationService = notificationService
        self.centralManager.delegate = self
    }
}

// MARK: - BLEManagerProtocol
extension BLEManager: BLEManagerProtocol {
    // MARK: State
    var discoveredDevices: AsyncStream<[PeripheralModel]> {
        scanningService.discoveredDevices
    }
    
    var isScanning: Bool {
        scanningService.isScanning
    }
    
    var isConnected: Bool {
        connectionService.isConnected
    }
    
    var connectedDevice: PeripheralModel? {
        connectionService.connectedDevice
    }
    
    // MARK: Scanning
    func startScanning() async throws {
        try validateBluetoothState()
        try await scanningService.startScanning()
    }
    
    func stopScanning() async {
        await scanningService.stopScanning()
    }
    
    // MARK: Connection
    func connect(to device: PeripheralModel) async throws {
        try validateBluetoothState()
        try await connectionService.connect(to: device)
    }
    
    func disconnect() async {
        await connectionService.disconnect()
    }
    
    // MARK: Device Operations
    func readAdvertisementData(for device: PeripheralModel) async throws -> [String: Any] {
        // Synchronous data access; keep signature for protocol uniformity
        return device.advertisementData
    }
    
    func clearDevices() async {
        await clearDiscoveredDevices()
    }
    
    func clearDiscoveredDevices() async {
        await scanningService.clearDiscoveredDevices()
    }
    
    // MARK: Service Discovery
    func discoverServices() async throws -> [CBService] {
        try await serviceExplorer.discoverServices()
    }
    
    func discoverCharacteristics(for service: CBService) async throws -> [CBCharacteristic] {
        try await serviceExplorer.discoverCharacteristics(for: service)
    }
    
    // MARK: Characteristic Operations
    func readValue(for characteristic: CBCharacteristic) async throws -> Data? {
        try await serviceExplorer.readValue(for: characteristic)
    }
    
    func writeValue(_ data: Data, for characteristic: CBCharacteristic, type: CBCharacteristicWriteType) async throws {
        try await serviceExplorer.writeValue(data, for: characteristic, type: type)
    }
    
    func setNotification(_ enabled: Bool, for characteristic: CBCharacteristic) async throws {
        if enabled {
            try await notificationService.subscribeToNotifications(for: characteristic)
        } else {
            try await notificationService.unsubscribeFromNotifications(for: characteristic)
        }
    }
}

// MARK: - CBCentralManagerDelegate
extension BLEManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        bluetoothState = central.state
        if central.state != .poweredOn {
            scanningService.handleScanStopped()
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
        scanningService.handleDiscoveredDevice(
            peripheral: peripheral,
            advertisementData: advertisementData,
            rssi: RSSI
        )
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        connectionService.handleDeviceConnected(peripheral: peripheral, devices: devices)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        connectionService.handleDeviceFailedToConnect(error: error)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectionService.handleDeviceDisconnected()
    }
}

// MARK: - CBPeripheralDelegate
extension BLEManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        serviceExplorer.handleServicesDiscovered(services: peripheral.services, error: error)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        serviceExplorer.handleCharacteristicsDiscovered(characteristics: service.characteristics, error: error)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        serviceExplorer.handleValueRead(value: characteristic.value, error: error)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        serviceExplorer.handleValueWritten(error: error)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        notificationService.handleNotificationStateChanged(error: error)
    }
}

// MARK: - Notification Methods
extension BLEManager {
    /// Subscribe to notifications for a characteristic
    func subscribeToNotifications(for characteristic: CBCharacteristic) async throws {
        try await notificationService.subscribeToNotifications(for: characteristic)
    }
    
    /// Unsubscribe from notifications for a characteristic
    func unsubscribeFromNotifications(for characteristic: CBCharacteristic) async throws {
        try await notificationService.unsubscribeFromNotifications(for: characteristic)
    }
    
    /// Check if currently subscribed to a characteristic
    func isSubscribed(to characteristic: CBCharacteristic) -> Bool {
        return notificationService.isSubscribed(to: characteristic)
    }
    
    /// Toggle notification subscription for a characteristic
    func toggleNotification(for characteristic: CBCharacteristic) async throws {
        try await notificationService.toggleNotification(for: characteristic)
    }
}

// MARK: - Private Helpers
private extension BLEManager {
    func validateBluetoothState() throws {
        guard bluetoothState == .poweredOn else {
            throw BLEError.bluetoothUnavailable
        }
    }
}
