//
//  DataValueFormatter.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import Foundation

enum DataValueFormatter {
    
    /// Formats Data as hexadecimal string
    static func formatAsHex(_ data: Data) -> String {
        data.map { String(format: "%02X", $0) }.joined(separator: " ")
    }
    
    /// Formats Data as UTF-8 string if possible
    static func formatAsString(_ data: Data) -> String? {
        String(data: data, encoding: .utf8)
    }
    
    /// Formats Data with both hex and string representation
    static func formatFull(_ data: Data) -> String {
        let hex = formatAsHex(data)
        if let string = formatAsString(data), !string.isEmpty {
            return "\(hex)\n(\(string))"
        }
        return hex
    }
    
    /// Formats Data as clean string only (no hex codes)
    static func formatCleanString(_ data: Data) -> String {
        if let string = formatAsString(data), !string.isEmpty {
            return string
        }
        return formatAsHex(data)
    }
    
    /// Formats optional Data with fallback message
    static func formatOptional(_ data: Data?, fallback: String = "No data") -> String {
        guard let data = data, !data.isEmpty else {
            return fallback
        }
        return formatAsHex(data)
    }
}

