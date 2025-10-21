//
//  ServicesViewModel.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import Foundation
import CoreBluetooth

final class ServicesViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var services: [CBService] = []
    @Published private(set) var characteristics: [CBUUID: [CBCharacteristic]] = [:]
    @Published private(set) var characteristicValues: [CBUUID: Data?] = [:] // Characteristic UUID -> Value
    @Published private(set) var discoveringServices: Set<CBUUID> = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    @Published var showingError = false
    
    // MARK: - Private Properties
    let device: PeripheralModel
    let bluetoothService: BLEManagerProtocol
    
    var viewState: ServicesViewState {
        ServicesViewState(
            services: services,
            characteristics: characteristics,
            characteristicValues: characteristicValues,
            discoveringServices: discoveringServices,
            isLoading: isLoading,
            device: device
        )
    }
    
    init(device: PeripheralModel, bluetoothService: BLEManagerProtocol) {
        self.device = device
        self.bluetoothService = bluetoothService
        
        Task {
            await monitorConnectionState()
        }
    }
    
    @MainActor
    private func monitorConnectionState() async {
        while true {
            // Check if device is still connected
            let isCurrentlyConnected = bluetoothService.isConnected && 
                                     bluetoothService.connectedDevice?.peripheral.identifier == device.peripheral.identifier
            
            if !isCurrentlyConnected && !services.isEmpty {
                // Device disconnected, clear services
                services = []
                characteristics = [:]
                characteristicValues = [:]
            }
            
            try? await Task.sleep(for: .seconds(2))
        }
    }
}

// MARK: - Public Methods
extension ServicesViewModel {
    @MainActor
    func loadServices() async {
        guard bluetoothService.isConnected else {
            handleError(BLEError.noConnectedDevice)
            return
        }
        
        isLoading = true
        
        do {
            let discoveredServices = try await bluetoothService.discoverServices()
            services = discoveredServices
            
            await discoverAllCharacteristics()
            
            isLoading = false
        } catch {
            isLoading = false
            handleError(error)
        }
    }
    
    @MainActor
    private func discoverAllCharacteristics() async {
        for service in services {
            do {
                let discoveredCharacteristics = try await bluetoothService.discoverCharacteristics(for: service)
                characteristics[service.uuid] = discoveredCharacteristics
                
                    await readCharacteristicValues(for: service, characteristics: discoveredCharacteristics)
            } catch {
                print("Failed to discover characteristics for service \(service.uuid): \(error)")
            }
        }
    }
    
    @MainActor
    private func readCharacteristicValues(for service: CBService, characteristics: [CBCharacteristic]) async {
        for characteristic in characteristics {
            if characteristic.properties.contains(.read) {
                do {
                    let value = try await bluetoothService.readValue(for: characteristic)
                    characteristicValues[characteristic.uuid] = value
                    print("Successfully read value for characteristic \(characteristic.uuid): \(value?.count ?? 0) bytes")
                } catch {
                    print("Failed to read value for characteristic \(characteristic.uuid): \(error)")
                    characteristicValues[characteristic.uuid] = nil
                }
            } else {
                characteristicValues[characteristic.uuid] = nil
            }
        }
    }
    
    @MainActor
    func discoverCharacteristics(for service: CBService) async {
        guard bluetoothService.isConnected else {
            handleError(BLEError.noConnectedDevice)
            return
        }
        
        discoveringServices.insert(service.uuid)
        
        do {
            let discoveredCharacteristics = try await bluetoothService.discoverCharacteristics(for: service)
            characteristics[service.uuid] = discoveredCharacteristics
            
            await readCharacteristicValues(for: service, characteristics: discoveredCharacteristics)
            
            discoveringServices.remove(service.uuid)
        } catch {
            discoveringServices.remove(service.uuid)
            handleError(error)
        }
    }
    
    @MainActor
    func refreshCharacteristicValues() async {
        guard bluetoothService.isConnected else {
            handleError(BLEError.noConnectedDevice)
            return
        }
        
        for (serviceUUID, serviceCharacteristics) in characteristics {
            if let service = services.first(where: { $0.uuid == serviceUUID }) {
                await readCharacteristicValues(for: service, characteristics: serviceCharacteristics)
            }
        }
    }
    
    @MainActor
    func readCharacteristic(_ characteristic: CBCharacteristic) async {
        guard bluetoothService.isConnected else {
            handleError(BLEError.noConnectedDevice)
            return
        }
        
        do {
            let value = try await bluetoothService.readValue(for: characteristic)
            characteristicValues[characteristic.uuid] = value
            print("Successfully read value for characteristic \(characteristic.uuid): \(value?.count ?? 0) bytes")
        } catch {
            print("Failed to read value for characteristic \(characteristic.uuid): \(error)")
            handleError(error)
        }
    }
    
    @MainActor
    func writeCharacteristic(_ characteristic: CBCharacteristic, data: Data) async {
        guard bluetoothService.isConnected else {
            handleError(BLEError.noConnectedDevice)
            return
        }
        
        do {
            try await bluetoothService.writeValue(data, for: characteristic, type: .withResponse)
            print("Successfully wrote value to characteristic \(characteristic.uuid): \(data.count) bytes")
        } catch {
            print("Failed to write value to characteristic \(characteristic.uuid): \(error)")
            handleError(error)
        }
    }
    
    @MainActor
    func toggleNotification(_ characteristic: CBCharacteristic) async {
        guard bluetoothService.isConnected else {
            handleError(BLEError.noConnectedDevice)
            return
        }
        
        do {
            try await bluetoothService.toggleNotification(for: characteristic)
            print("Successfully toggled notifications for characteristic \(characteristic.uuid)")
        } catch {
            print("Failed to toggle notifications for characteristic \(characteristic.uuid): \(error)")
            handleError(error)
        }
    }
}

// MARK: - Private Methods
private extension ServicesViewModel {
    func handleError(_ error: Error) {
        Task { @MainActor in
            self.errorMessage = error.localizedDescription
            self.showingError = true
        }
    }
    
    
}
