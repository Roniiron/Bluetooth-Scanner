//
//  CBPeripheral+Extensions.swift
//  Bluetooth Scanner
//
//  Created by Roni on 13. 10. 2025..
//

import Foundation
import CoreBluetooth

/// Extensions for CBPeripheral to support our modern architecture
extension CBPeripheral {
    
    /// Convenience initializer for creating mock peripherals
    convenience init(identifier: UUID = UUID(), name: String? = nil) {
        self.init()
        // Note: In real usage, CBPeripheral is created by CoreBluetooth
        // This is just for preview/testing purposes
    }
}
