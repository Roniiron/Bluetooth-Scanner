//
//  ServicesViewState.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import Foundation
import CoreBluetooth

/// Encapsulates all presentation logic for ServicesView
struct ServicesViewState {
    // MARK: - Properties
    let services: [CBService]
    let characteristics: [CBUUID: [CBCharacteristic]] // Service UUID -> Characteristics
    let characteristicValues: [CBUUID: Data?] // Characteristic UUID -> Value
    let discoveringServices: Set<CBUUID> // Service UUIDs currently being discovered
    let isLoading: Bool
    let device: PeripheralModel
    
    // MARK: - Services State
    var hasServices: Bool {
        !services.isEmpty
    }
    
    var shouldShowEmptyState: Bool {
        services.isEmpty && !isLoading
    }
    
    var servicesCount: Int {
        services.count
    }
    
    var servicesCountText: String {
        if services.isEmpty {
            return L10n.Details.noServices
        } else if services.count == 1 {
            return L10n.Details.oneService
        } else {
            return L10n.Details.multipleServices(services.count)
        }
    }
    
    // MARK: - Characteristics State
    func characteristics(for service: CBService) -> [CBCharacteristic] {
        characteristics[service.uuid] ?? []
    }
    
    func isServiceDiscovering(_ service: CBService) -> Bool {
        discoveringServices.contains(service.uuid)
    }
    
    func value(for characteristic: CBCharacteristic) -> Data? {
        characteristicValues[characteristic.uuid] ?? nil
    }
    
    func formattedValue(for characteristic: CBCharacteristic) -> String {
        guard let value = characteristicValues[characteristic.uuid] ?? nil else {
            if characteristic.properties.contains(.read) {
                return "No value available"
            } else {
                return "Not readable"
            }
        }
        
        return DataValueFormatter.formatCleanString(value)
    }
}
