//
//  BLEConstants.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import Foundation

/// Constants used throughout the BLE layer
enum BLEConstants {
    enum Timeout {
        static let connection: TimeInterval = 10.0
        static let operation: TimeInterval = 5.0
    }
    
    enum DeviceState {
        static let staleThreshold: TimeInterval = 15.0
    }
}

