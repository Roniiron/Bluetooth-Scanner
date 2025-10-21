//
//  BLEError.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import Foundation

/// Errors that can occur during BLE operations
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
    case invalidOperation(String)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .bluetoothUnavailable:
            return "Bluetooth is not available"
        case .scanningFailed:
            return "Failed to start scanning"
        case let .connectionFailed(error):
            return "Connection failed: \(error.localizedDescription)"
        case let .serviceDiscoveryFailed(error):
            return "Service discovery failed: \(error.localizedDescription)"
        case let .characteristicDiscoveryFailed(error):
            return "Characteristic discovery failed: \(error.localizedDescription)"
        case let .readValueFailed(error):
            return "Read failed: \(error.localizedDescription)"
        case let .writeValueFailed(error):
            return "Write failed: \(error.localizedDescription)"
        case let .notificationFailed(error):
            return "Notification setup failed: \(error.localizedDescription)"
        case .noConnectedDevice:
            return "No device connected"
        case .invalidState:
            return "Invalid state"
        case .timeout:
            return "Operation timed out"
        case .invalidOperation(let message):
            return message
        case .unknown:
            return "Unknown error"
        }
    }
}

