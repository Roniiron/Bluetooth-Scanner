//
//  CharacteristicPropertyFormatter.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import Foundation
import CoreBluetooth

enum CharacteristicPropertyFormatter {
    /// Extracts property names from CBCharacteristicProperties
    static func formatProperties(_ properties: CBCharacteristicProperties) -> [String] {
        var result: [String] = []
        
        if properties.contains(.read) { result.append("Read") }
        if properties.contains(.write) { result.append("Write") }
        if properties.contains(.writeWithoutResponse) { result.append("Write Without Response") }
        if properties.contains(.notify) { result.append("Notify") }
        if properties.contains(.indicate) { result.append("Indicate") }
        if properties.contains(.authenticatedSignedWrites) { result.append("Authenticated Signed Writes") }
        if properties.contains(.extendedProperties) { result.append("Extended Properties") }
        if properties.contains(.notifyEncryptionRequired) { result.append("Notify Encryption Required") }
        if properties.contains(.indicateEncryptionRequired) { result.append("Indicate Encryption Required") }
        
        return result
    }
    
    /// Formats properties as comma-separated string
    static func formatPropertiesString(_ properties: CBCharacteristicProperties) -> String {
        let props = formatProperties(properties)
        return props.isEmpty ? "None" : props.joined(separator: ", ")
    }
    
    /// Check if characteristic is readable
    static func isReadable(_ properties: CBCharacteristicProperties) -> Bool {
        properties.contains(.read)
    }
    
    /// Check if characteristic is writable
    static func isWritable(_ properties: CBCharacteristicProperties) -> Bool {
        properties.contains(.write) || properties.contains(.writeWithoutResponse)
    }
    
    /// Check if characteristic supports notifications
    static func supportsNotifications(_ properties: CBCharacteristicProperties) -> Bool {
        properties.contains(.notify) || properties.contains(.indicate)
    }
}

