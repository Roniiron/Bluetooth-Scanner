//
//  BLEStateProtocol.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import CoreBluetooth

/// Protocol for observing Bluetooth adapter state
protocol BLEStateProtocol {
    /// Current Bluetooth adapter state
    var bluetoothState: CBManagerState { get }
}

