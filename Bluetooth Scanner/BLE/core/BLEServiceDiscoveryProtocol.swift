//
//  BLEServiceDiscoveryProtocol.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import CoreBluetooth

/// Protocol for discovering BLE services and characteristics
protocol BLEServiceDiscoveryProtocol {
    /// Discover all services for the connected device
    func discoverServices() async throws -> [CBService]
    
    /// Discover characteristics for a specific service
    func discoverCharacteristics(for service: CBService) async throws -> [CBCharacteristic]
}

