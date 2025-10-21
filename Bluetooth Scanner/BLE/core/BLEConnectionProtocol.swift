//
//  BLEConnectionProtocol.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import Foundation

/// Protocol for BLE device connection management
protocol BLEConnectionProtocol {
    /// Whether a device is currently connected
    var isConnected: Bool { get }
    
    /// The currently connected device
    var connectedDevice: PeripheralModel? { get }
    
    /// Connect to a specific device
    func connect(to device: PeripheralModel) async throws
    
    /// Disconnect from the current device
    func disconnect() async
}

