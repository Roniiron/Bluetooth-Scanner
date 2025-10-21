//
//  PeripheralPresentation.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import Foundation
import CoreBluetooth

/// Extension containing presentation logic for PeripheralModel
/// Separates display concerns from core model
extension PeripheralModel {
    // MARK: - Display Properties
    /// Formatted RSSI value for display
    var rssiString: String {
        "\(rssi) dBm"
    }
    
    /// Display name (peripheral name or "Unknown Device")
    var displayName: String {
        name ?? "Unknown Device"
    }
    
    /// Whether device is stale (not seen recently)
    var isStale: Bool {
        Date().timeIntervalSince(lastSeen) > BLEConstants.DeviceState.staleThreshold
    }
    
    /// Service UUIDs formatted as strings for display
    var serviceUUIDs: [String] {
        services.map { $0.uuidString }
    }
    
    /// Formatted advertisement data for display
    var formattedAdvertisementData: [(label: String, value: String)] {
        AdvertisementDataFormatter.format(advertisementData)
    }
    
    /// Formatted device identifier (like E112-8559-435F-5176)
    var formattedIdentifier: String {
        let uuidString = peripheral.identifier.uuidString
        let components = uuidString.split(separator: "-")
        
        if components.count >= 3 {
            // Format: XXXX-XXXX-XXXX-XXXX using first 16 characters
            return "\(components[0].prefix(4))-\(components[0].suffix(4))-\(components[1])-\(components[2])"
                .uppercased()
        }
        
        return uuidString.uppercased()
    }
    
    /// Full UUID string for the device
    var fullUUID: String {
        peripheral.identifier.uuidString.uppercased()
    }
}

/// Utility for formatting advertisement data
enum AdvertisementDataFormatter {
    static func format(_ data: [String: Any]) -> [(label: String, value: String)] {
        var result: [(label: String, value: String)] = []
        
        for key in data.keys.sorted() {
            let displayName = getDisplayName(for: key)
            let displayValue = getDisplayValue(from: data, key: key)
            
            if !displayValue.isEmpty {
                result.append((label: displayName, value: displayValue))
            }
        }
        
        return result
    }
    
    // MARK: - Private Helpers
    private static func getDisplayName(for key: String) -> String {
        switch key {
        case CBAdvertisementDataLocalNameKey:
            return "Local Name"
        case CBAdvertisementDataTxPowerLevelKey:
            return "Tx Power Level"
        case CBAdvertisementDataServiceUUIDsKey:
            return "Service UUIDs"
        case CBAdvertisementDataServiceDataKey:
            return "Service Data"
        case CBAdvertisementDataManufacturerDataKey:
            return "Manufacturer Data"
        case CBAdvertisementDataOverflowServiceUUIDsKey:
            return "Overflow Service UUIDs"
        case CBAdvertisementDataIsConnectable:
            return "Device is Connectable"
        case CBAdvertisementDataSolicitedServiceUUIDsKey:
            return "Solicited Service UUIDs"
        default:
            return key
        }
    }
    
    private static func getDisplayValue(from data: [String: Any], key: String) -> String {
        switch key {
        case CBAdvertisementDataLocalNameKey:
            return (data[key] as? String) ?? ""
            
        case CBAdvertisementDataTxPowerLevelKey:
            return (data[key] as? String) ?? ""
            
        case CBAdvertisementDataServiceUUIDsKey:
            guard let serviceUUIDs = data[key] as? [CBUUID] else { return "" }
            return serviceUUIDs.map { $0.uuidString }.joined(separator: ", ")
            
        case CBAdvertisementDataServiceDataKey:
            guard let serviceData = data[key] as? NSDictionary else { return "" }
            return serviceData.description
                .replacingOccurrences(of: "\n", with: "")
                .replacingOccurrences(of: " ", with: "")
            
        case CBAdvertisementDataManufacturerDataKey:
            return (data[key] as? Data)?.description ?? ""
            
        case CBAdvertisementDataIsConnectable:
            guard let connectable = data[key] as? NSNumber else { return "" }
            return connectable.boolValue ? "true" : "false"
            
        case CBAdvertisementDataOverflowServiceUUIDsKey,
             CBAdvertisementDataSolicitedServiceUUIDsKey:
            return ""
            
        default:
            return ""
        }
    }
}

