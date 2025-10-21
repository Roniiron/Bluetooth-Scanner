//
//  LoadingState.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import Foundation

/// Loading/initialization state of the device list
enum LoadingState: Equatable {
    case initializing        // App just opened, Bluetooth state unknown
    case idle               // Ready to scan, never scanned before or cleared devices
    case scanning           // Actively scanning
    case scanningStopped    // Stopped scanning with results
    case error(String)      // Error state
    
    var isInitializing: Bool {
        if case .initializing = self { return true }
        return false
    }
    
    var isScanning: Bool {
        if case .scanning = self { return true }
        return false
    }
    
    var isIdle: Bool {
        if case .idle = self { return true }
        return false
    }
    
    var hasScannedBefore: Bool {
        switch self {
        case .scanning, .scanningStopped:
            return true
        default:
            return false
        }
    }
}

