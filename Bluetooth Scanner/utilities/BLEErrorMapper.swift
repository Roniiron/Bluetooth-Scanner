//
//  BLEErrorMapper.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import Foundation
import CoreBluetooth

enum BLEErrorMapper {
    static func userMessage(for error: Error) -> String {
        if let bleError = error as? BLEError {
            return bleError.errorDescription ?? "Unknown error"
        }
        if let cbError = error as? CBError {
            return message(for: cbError)
        }
        return error.localizedDescription
    }
    
    private static func message(for error: CBError) -> String {
        switch error.code {
        case .unknown:
            return "Bluetooth error occurred"
        case .invalidParameters:
            return "Invalid Bluetooth parameters provided"
        case .invalidHandle:
            return "Invalid Bluetooth handle"
        case .notConnected:
            return "Device not connected"
        case .operationCancelled:
            return "Operation cancelled"
        case .connectionTimeout:
            return "Connection timed out"
        case .peripheralDisconnected:
            return "Peripheral disconnected"
        case .connectionFailed:
            return "Connection failed"
        default:
            return (error as NSError).localizedDescription
        }
    }
}


