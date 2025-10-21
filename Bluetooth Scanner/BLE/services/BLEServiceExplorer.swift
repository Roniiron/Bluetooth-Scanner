//
//  BLEServiceExplorer.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import Foundation
import CoreBluetooth

/// Service responsible for discovering BLE services and characteristics
protocol BLEServiceExplorerProtocol: BLEServiceDiscoveryProtocol, BLECharacteristicProtocol {
    func handleServicesDiscovered(services: [CBService]?, error: Error?)
    func handleCharacteristicsDiscovered(characteristics: [CBCharacteristic]?, error: Error?)
    func handleValueRead(value: Data?, error: Error?)
    func handleValueWritten(error: Error?)
}

final class BLEServiceExplorer: BLEServiceExplorerProtocol {
    private let connectionService: BLEConnectionService
    
    private var serviceDiscoveryContinuation: CheckedContinuation<[CBService], Error>?
    private var characteristicDiscoveryContinuation: CheckedContinuation<[CBCharacteristic], Error>?
    private var readValueContinuation: CheckedContinuation<Data?, Error>?
    private var writeValueContinuation: CheckedContinuation<Void, Error>?
    
    init(connectionService: BLEConnectionService) {
        self.connectionService = connectionService
    }
}

// MARK: - Public
extension BLEServiceExplorer {
    func handleServicesDiscovered(services: [CBService]?, error: Error?) {
        if let error = error {
            serviceDiscoveryContinuation?.resume(throwing: BLEError.serviceDiscoveryFailed(error))
        } else {
            serviceDiscoveryContinuation?.resume(returning: services ?? [])
        }
        serviceDiscoveryContinuation = nil
    }
    
    func handleCharacteristicsDiscovered(characteristics: [CBCharacteristic]?, error: Error?) {
        if let error = error {
            characteristicDiscoveryContinuation?.resume(throwing: BLEError.characteristicDiscoveryFailed(error))
        } else {
            characteristicDiscoveryContinuation?.resume(returning: characteristics ?? [])
        }
        characteristicDiscoveryContinuation = nil
    }
    
    func handleValueRead(value: Data?, error: Error?) {
        if let error = error {
            readValueContinuation?.resume(throwing: BLEError.readValueFailed(error))
        } else {
            readValueContinuation?.resume(returning: value)
        }
        readValueContinuation = nil
    }
    
    func handleValueWritten(error: Error?) {
        if let error = error {
            writeValueContinuation?.resume(throwing: BLEError.writeValueFailed(error))
        } else {
            writeValueContinuation?.resume()
        }
        writeValueContinuation = nil
    }
    
}

// MARK: - BLEServiceDiscoveryProtocol
extension BLEServiceExplorer: BLEServiceDiscoveryProtocol {
    func discoverServices() async throws -> [CBService] {
        guard let device = connectionService.connectedDevice else {
            throw BLEError.noConnectedDevice
        }
        
        return try await ConcurrencyTimeouts.withTimeout(BLEConstants.Timeout.operation) {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[CBService], Error>) in
                self.serviceDiscoveryContinuation = continuation
                device.peripheral.discoverServices(nil)
            }
        }
    }
    
    func discoverCharacteristics(for service: CBService) async throws -> [CBCharacteristic] {
        guard let device = connectionService.connectedDevice else {
            throw BLEError.noConnectedDevice
        }
        
        return try await ConcurrencyTimeouts.withTimeout(BLEConstants.Timeout.operation) {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[CBCharacteristic], Error>) in
                self.characteristicDiscoveryContinuation = continuation
                device.peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
}

// MARK: - BLECharacteristicProtocol
extension BLEServiceExplorer: BLECharacteristicProtocol {
    func readValue(for characteristic: CBCharacteristic) async throws -> Data? {
        guard let device = connectionService.connectedDevice else {
            throw BLEError.noConnectedDevice
        }
        
        return try await ConcurrencyTimeouts.withTimeout(BLEConstants.Timeout.operation) {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Data?, Error>) in
                self.readValueContinuation = continuation
                device.peripheral.readValue(for: characteristic)
            }
        }
    }
    
    func writeValue(_ data: Data, for characteristic: CBCharacteristic, type: CBCharacteristicWriteType) async throws {
        guard let device = connectionService.connectedDevice else {
            throw BLEError.noConnectedDevice
        }
        
        try await ConcurrencyTimeouts.withTimeout(BLEConstants.Timeout.operation) {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                self.writeValueContinuation = continuation
                device.peripheral.writeValue(data, for: characteristic, type: type)
            }
        }
    }
    
    func setNotification(_ enabled: Bool, for characteristic: CBCharacteristic) async throws {
        guard let device = connectionService.connectedDevice else {
            throw BLEError.noConnectedDevice
        }
        device.peripheral.setNotifyValue(enabled, for: characteristic)
    }
}
