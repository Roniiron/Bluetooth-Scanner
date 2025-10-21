//
//  BLEConnectionService.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import Foundation
import CoreBluetooth

/// Service responsible for BLE device connection management
protocol BLEConnectionServiceProtocol: BLEConnectionProtocol {
    func handleDeviceConnected(peripheral: CBPeripheral, devices: [UUID: PeripheralModel])
    func handleDeviceFailedToConnect(error: Error?)
    func handleDeviceDisconnected()
}

final class BLEConnectionService: BLEConnectionServiceProtocol {
    private let centralManager: CBCentralManager
    private var connectionContinuation: CheckedContinuation<Void, Error>?
    
    private(set) var connectedDevice: PeripheralModel?
    
    init(centralManager: CBCentralManager) {
        self.centralManager = centralManager
    }
    
    // MARK: - Public Methods
    func handleDeviceConnected(peripheral: CBPeripheral, devices: [UUID: PeripheralModel]) {
        guard let device = devices[peripheral.identifier] else {
            connectionContinuation?.resume(throwing: BLEError.unknown)
            connectionContinuation = nil
            return
        }
        
        connectedDevice = device
        connectionContinuation?.resume()
        connectionContinuation = nil
    }
    
    func handleDeviceFailedToConnect(error: Error?) {
        connectionContinuation?.resume(throwing: BLEError.connectionFailed(error ?? BLEError.unknown))
        connectionContinuation = nil
    }
    
    func handleDeviceDisconnected() {
        connectedDevice = nil
    }
}

// MARK: - BLEConnectionProtocol
extension BLEConnectionService: BLEConnectionProtocol {
    var isConnected: Bool {
        connectedDevice != nil
    }
    
    func connect(to device: PeripheralModel) async throws {
        // If already connected to a different device, disconnect first
        if let currentDevice = connectedDevice, currentDevice.peripheral.identifier != device.peripheral.identifier {
            BLELogger.logDisconnection(deviceName: currentDevice.displayName, reason: "Switching to new device")
            await disconnect()
        }
        
        // If trying to connect to the same device that's already connected, just return
        if let currentDevice = connectedDevice, currentDevice.peripheral.identifier == device.peripheral.identifier {
            BLELogger.logConnectionSuccess(deviceName: device.displayName, duration: 0.0)
            return
        }
        
        BLELogger.logConnectionAttempt(deviceName: device.displayName)
        let startTime = Date()
        
        try await ConcurrencyTimeouts.withTimeout(BLEConstants.Timeout.connection) {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                self.connectionContinuation = continuation
                self.centralManager.connect(
                    device.peripheral,
                    options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey: true]
                )
            }
        }
        
        let duration = Date().timeIntervalSince(startTime)
        BLELogger.logConnectionSuccess(deviceName: device.displayName, duration: duration)
    }
    
    func disconnect() async {
        guard let device = connectedDevice else { return }
        
        centralManager.cancelPeripheralConnection(device.peripheral)
        connectedDevice = nil
    }
}
