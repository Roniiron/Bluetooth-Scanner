//
//  BLEManagerProtocol.swift
//  Bluetooth Scanner
//
//  Created by Roni on 13. 10. 2025..
//

import CoreBluetooth

protocol BLEManagerProtocol {
    // MARK: State
    var discoveredDevices: AsyncStream<[PeripheralModel]> { get }
    var isScanning: Bool { get }
    var isConnected: Bool { get }
    var connectedDevice: PeripheralModel? { get }
    var bluetoothState: CBManagerState { get }
    
    // MARK: Scanning
    func startScanning() async throws
    func stopScanning() async
    
    // MARK: Connection
    func connect(to device: PeripheralModel) async throws
    func disconnect() async
    
    // MARK: Device Operations
    func readAdvertisementData(for device: PeripheralModel) async throws -> [String: Any]
    func clearDevices() async
    
    // MARK: Service Discovery
    func discoverServices() async throws -> [CBService]
    func discoverCharacteristics(for service: CBService) async throws -> [CBCharacteristic]
    
    // MARK: Characteristic Operations
    func readValue(for characteristic: CBCharacteristic) async throws -> Data?
    func writeValue(_ data: Data, for characteristic: CBCharacteristic, type: CBCharacteristicWriteType) async throws
    func setNotification(_ enabled: Bool, for characteristic: CBCharacteristic) async throws
}

// MARK: - BLEError
enum BLEError: LocalizedError {
    case bluetoothUnavailable
    case scanningFailed
    case connectionFailed(Error)
    case serviceDiscoveryFailed(Error)
    case characteristicDiscoveryFailed(Error)
    case readValueFailed(Error)
    case writeValueFailed(Error)
    case notificationFailed(Error)
    case noConnectedDevice
    case invalidState
    case timeout
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .bluetoothUnavailable:
            return "Bluetooth is not available"
        case .scanningFailed:
            return "Failed to start scanning"
        case .connectionFailed(let error):
            return "Connection failed: \(error.localizedDescription)"
        case .serviceDiscoveryFailed(let error):
            return "Service discovery failed: \(error.localizedDescription)"
        case .characteristicDiscoveryFailed(let error):
            return "Characteristic discovery failed: \(error.localizedDescription)"
        case .readValueFailed(let error):
            return "Read failed: \(error.localizedDescription)"
        case .writeValueFailed(let error):
            return "Write failed: \(error.localizedDescription)"
        case .notificationFailed(let error):
            return "Notification setup failed: \(error.localizedDescription)"
        case .noConnectedDevice:
            return "No device connected"
        case .invalidState:
            return "Invalid state"
        case .timeout:
            return "Operation timed out"
        case .unknown:
            return "Unknown error"
        }
    }
}
