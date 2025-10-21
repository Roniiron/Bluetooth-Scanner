//
//  DeviceDetailViewModel.swift
//  Bluetooth Scanner
//
//  Created by Roni on 13. 10. 2025..
//

import Foundation
import CoreBluetooth

/// ViewModel for managing device details and services
final class DeviceDetailViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var services: [CBService] = []
    @Published var characteristics: [CBCharacteristic] = []
    @Published var selectedService: CBService?
    @Published var selectedCharacteristic: CBCharacteristic?
    @Published var characteristicValue: Data?
    @Published var isDiscoveringServices = false
    @Published var isDiscoveringCharacteristics = false
    @Published var isReadingValue = false
    @Published var errorMessage: String?
    @Published var showingError = false
    @Published var isConnected = false
    
    // MARK: - Private Properties
    
    private let bluetoothService: BLEManagerProtocol
    private let device: PeripheralModel
    
    // MARK: - Initialization
    
    init(device: PeripheralModel, bluetoothService: BLEManagerProtocol = BLEManager()) {
        self.device = device
        self.bluetoothService = bluetoothService
    }
    
    // MARK: - Public Methods
    
    func connectToDevice() {
        Task {
            do {
                try await bluetoothService.connect(to: device)
                await MainActor.run {
                    self.isConnected = true
                }
                // Auto-discover services after connection
                discoverServices()
            } catch {
                await handleError(error)
            }
        }
    }
    
    func disconnectFromDevice() {
        Task {
            await bluetoothService.disconnect()
            await MainActor.run {
                self.isConnected = false
                self.services = []
                self.characteristics = []
            }
        }
    }
    
    func discoverServices() {
        guard bluetoothService.isConnected else {
            handleError(BLEError.noConnectedDevice)
            return
        }
        
        Task { @MainActor in
            self.isDiscoveringServices = true
        }
        
        Task {
            do {
                let discoveredServices = try await bluetoothService.discoverServices()
                await MainActor.run {
                    self.services = discoveredServices
                    self.isDiscoveringServices = false
                }
            } catch {
                await MainActor.run {
                    self.isDiscoveringServices = false
                }
                await handleError(error)
            }
        }
    }
    
    func discoverCharacteristics(for service: CBService) {
        guard bluetoothService.isConnected else {
            handleError(BLEError.noConnectedDevice)
            return
        }
        
        Task { @MainActor in
            self.isDiscoveringCharacteristics = true
            self.selectedService = service
        }
        
        Task {
            do {
                let discoveredCharacteristics = try await bluetoothService.discoverCharacteristics(for: service)
                await MainActor.run {
                    self.characteristics = discoveredCharacteristics
                    self.isDiscoveringCharacteristics = false
                }
            } catch {
                await MainActor.run {
                    self.isDiscoveringCharacteristics = false
                }
                await handleError(error)
            }
        }
    }
    
    func readValue(for characteristic: CBCharacteristic) {
        guard bluetoothService.isConnected else {
            handleError(BLEError.noConnectedDevice)
            return
        }
        
        Task { @MainActor in
            self.isReadingValue = true
            self.selectedCharacteristic = characteristic
        }
        
        Task {
            do {
                let value = try await bluetoothService.readValue(for: characteristic)
                await MainActor.run {
                    self.characteristicValue = value
                    self.isReadingValue = false
                }
            } catch {
                await MainActor.run {
                    self.isReadingValue = false
                }
                await handleError(error)
            }
        }
    }
    
    func writeValue(_ data: Data, for characteristic: CBCharacteristic, type: CBCharacteristicWriteType) {
        guard bluetoothService.isConnected else {
            handleError(BLEError.noConnectedDevice)
            return
        }
        
        Task {
            do {
                try await bluetoothService.writeValue(data, for: characteristic, type: type)
            } catch {
                await handleError(error)
            }
        }
    }
    
    func setNotification(_ enabled: Bool, for characteristic: CBCharacteristic) {
        guard bluetoothService.isConnected else {
            handleError(BLEError.noConnectedDevice)
            return
        }
        
        Task {
            do {
                try await bluetoothService.setNotification(enabled, for: characteristic)
            } catch {
                await handleError(error)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func handleError(_ error: Error) {
        Task { @MainActor in
            self.errorMessage = error.localizedDescription
            self.showingError = true
        }
    }
}

// MARK: - Computed Properties

extension DeviceDetailViewModel {
    
    var deviceName: String {
        device.displayName
    }
    
    var deviceRSSI: String {
        device.rssiString
    }
    
    var advertisementData: String {
        device.advertisementDataString
    }
    
    var serviceUUIDs: [String] {
        device.serviceUUIDs
    }
    
    var manufacturerData: String {
        guard let data = device.manufacturerData else {
            return "No manufacturer data"
        }
        return data.map { String(format: "%02X", $0) }.joined(separator: " ")
    }
    
    var txPowerLevel: String {
        guard let power = device.txPowerLevel else {
            return "Unknown"
        }
        return "\(power) dBm"
    }
    
    var isConnectableString: String {
        device.isConnectable ? "Yes" : "No"
    }
    
    var isConnectable: Bool {
        device.isConnectable
    }
    
    var characteristicValueString: String {
        guard let data = characteristicValue else {
            return "No value"
        }
        return data.map { String(format: "%02X", $0) }.joined(separator: " ")
    }
    
    var characteristicValueAsString: String {
        guard let data = characteristicValue,
              let string = String(data: data, encoding: .utf8) else {
            return "Not a valid string"
        }
        return string
    }
}
