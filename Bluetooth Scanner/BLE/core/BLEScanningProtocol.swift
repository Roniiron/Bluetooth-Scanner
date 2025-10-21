//
//  BLEScanningProtocol.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import Foundation

/// Protocol for BLE device scanning operations
protocol BLEScanningProtocol {
    /// Stream of discovered devices
    var discoveredDevices: AsyncStream<[PeripheralModel]> { get }
    
    /// Current scanning state
    var isScanning: Bool { get }
    
    /// Start scanning for nearby Bluetooth devices
    func startScanning() async throws
    
    /// Stop scanning for devices
    func stopScanning() async
    
    /// Clear all discovered devices
    func clearDiscoveredDevices() async
}

