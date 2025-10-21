//
//  BLECharacteristicProtocol.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import CoreBluetooth

/// Protocol for BLE characteristic read/write operations
protocol BLECharacteristicProtocol {
    /// Read value from a characteristic
    func readValue(for characteristic: CBCharacteristic) async throws -> Data?
    
    /// Write value to a characteristic
    func writeValue(_ data: Data, for characteristic: CBCharacteristic, type: CBCharacteristicWriteType) async throws
    
    /// Enable/disable notifications for a characteristic
    func setNotification(_ enabled: Bool, for characteristic: CBCharacteristic) async throws
}

