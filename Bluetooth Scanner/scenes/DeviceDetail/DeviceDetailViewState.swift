//
//  DeviceDetailViewState.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import Foundation
import CoreBluetooth

/// View state that encapsulates all presentation logic for DeviceDetailView
struct DeviceDetailViewState {
    // MARK: - Properties
    let device: PeripheralModel
    let services: [CBService]
    let characteristics: [CBCharacteristic]
    let selectedService: CBService?
    let selectedCharacteristic: CBCharacteristic?
    let characteristicValue: Data?
    let isDiscoveringCharacteristics: Bool
    let isReadingValue: Bool
    let connectionState: ConnectionState
    let errorMessage: String?
    let showingError: Bool
    
    // MARK: - Device Information
    var deviceName: String {
        device.displayName
    }
    
    var deviceRSSI: String {
        device.rssiString
    }
    
    var isConnectable: Bool {
        device.isConnectable
    }
    
    var isConnectableString: String {
        device.isConnectable ? L10n.Device.yes : L10n.Device.no
    }
    
    var manufacturerData: String {
        DataValueFormatter.formatOptional(
            device.manufacturerData,
            fallback: L10n.Details.noManufacturerData
        )
    }
    
    var txPowerLevel: String {
        guard let power = device.txPowerLevel else {
            return L10n.Device.unknown
        }
        return "\(power) dBm"
    }
    
    var deviceIdentifier: String {
        device.formattedIdentifier
    }
    
    var deviceUUID: String {
        device.fullUUID
    }
    
    // MARK: - Advertisement Data
    var serviceUUIDs: [String] {
        device.serviceUUIDs
    }
    
    var advertisementData: String {
        device.formattedAdvertisementData
            .map { "\($0.label): \($0.value)" }
            .joined(separator: "\n")
    }
    
    // MARK: - Connection State
    var connectionStateText: String {
        switch connectionState {
        case .notConnectable:
            return L10n.Device.notConnectable
        case .connected:
            return L10n.Device.connected
        case .disconnected:
            return isConnectable ? L10n.Device.connectable : L10n.Device.disconnected
        case .connecting, .discoveringServices, .interrogating, .disconnecting:
            return isConnectable ? L10n.Device.connectable : L10n.Device.disconnected
        }
    }
    
    var connectionStateOverlayText: String {
        connectionState.displayText
    }
    
    var isConnectionLoading: Bool {
        connectionState.isLoading
    }
    
    var canConnect: Bool {
        connectionState.canConnect
    }
    
    var canDisconnect: Bool {
        connectionState.canDisconnect
    }
    
    var showConnectionStateOverlay: Bool {
        isConnectionLoading
    }
    
    var isConnected: Bool {
        connectionState == .connected
    }
    
    // MARK: - Services State
    var hasServices: Bool {
        !services.isEmpty
    }
    
    var showServicesEmptyState: Bool {
        services.isEmpty && isConnected && !isConnectionLoading
    }
    
    var servicesEmptyStateText: String {
        L10n.Details.noServicesDiscovered
    }
    
    var shouldShowServices: Bool {
        isConnected && !isConnectionLoading
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
    var hasCharacteristics: Bool {
        !characteristics.isEmpty
    }
    
    var characteristicValueFormatted: String {
        guard let data = characteristicValue else {
            return L10n.Device.unknown
        }
        return DataValueFormatter.formatFull(data)
    }
    
    func isServiceDiscovering(_ service: CBService) -> Bool {
        isDiscoveringCharacteristics && selectedService == service
    }
    
    func isCharacteristicReading(_ characteristic: CBCharacteristic) -> Bool {
        isReadingValue && selectedCharacteristic == characteristic
    }
}
