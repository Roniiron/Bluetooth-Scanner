//
//  PeripheralModel.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import Foundation
import CoreBluetooth

/// Core model representing a discovered Bluetooth peripheral
/// Contains only essential device data, no presentation logic
struct PeripheralModel: Identifiable, Equatable, Hashable {
    // MARK: - Properties
    let id: UUID
    let peripheral: CBPeripheral
    let name: String?
    let rssi: Int
    let advertisementData: [String: Any]
    let lastSeen: Date
    
    init(
        peripheral: CBPeripheral,
        rssi: Int,
        advertisementData: [String: Any]
    ) {
        self.id = peripheral.identifier
        self.peripheral = peripheral
        self.name = peripheral.name ?? advertisementData[CBAdvertisementDataLocalNameKey] as? String
        self.rssi = rssi
        self.advertisementData = advertisementData
        self.lastSeen = Date()
    }
    
    // MARK: - Computed Properties
    /// Service UUIDs advertised by the device (as CBUUID objects)
    var services: [CBUUID] {
        (advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID]) ?? []
    }
    
    /// Manufacturer data if available
    var manufacturerData: Data? {
        advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data
    }
    
    /// TX Power Level if available
    var txPowerLevel: NSNumber? {
        advertisementData[CBAdvertisementDataTxPowerLevelKey] as? NSNumber
    }
    
    /// Whether the device is connectable
    var isConnectable: Bool {
        advertisementData[CBAdvertisementDataIsConnectable] as? Bool ?? false
    }
}

// MARK: - Equatable
extension PeripheralModel {
    static func == (lhs: PeripheralModel, rhs: PeripheralModel) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Hashable
extension PeripheralModel {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

