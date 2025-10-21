//
//  DeviceFilterService.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import Foundation

/// Service responsible for filtering and managing device lists
final class DeviceFilterService {
    
    /// Filters devices by RSSI threshold
    func filterByRSSI(devices: [PeripheralModel], minimumRSSI: Int) -> [PeripheralModel] {
        devices.filter { $0.rssi >= minimumRSSI }
    }
    
    /// Filters devices by search text
    func filterBySearchText(devices: [PeripheralModel], searchText: String) -> [PeripheralModel] {
        guard !searchText.isEmpty else { return devices }
        return devices.filter { device in
            device.displayName.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    /// Sorts devices by signal strength (strongest first)
    func sortBySignalStrength(devices: [PeripheralModel]) -> [PeripheralModel] {
        devices.sorted { $0.rssi > $1.rssi }
    }
    
    /// Updates device list maintaining FIFO order while updating existing devices
    func updateDeviceList(
        currentDevices: [PeripheralModel],
        newDevices: [PeripheralModel]
    ) -> [PeripheralModel] {
        let currentDeviceIds = Set(currentDevices.map { $0.id })
        let newlyDiscovered = newDevices.filter { !currentDeviceIds.contains($0.id) }
        
        var updatedDevices = currentDevices
        
        // Update existing devices with latest data without changing position
        for i in 0..<updatedDevices.count {
            if let updatedDevice = newDevices.first(where: { $0.id == updatedDevices[i].id }) {
                updatedDevices[i] = updatedDevice
            }
        }
        
        // Append newly discovered devices
        updatedDevices.append(contentsOf: newlyDiscovered)
        
        return updatedDevices
    }
}

