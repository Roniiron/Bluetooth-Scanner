//
//  DeviceDetailViewModel.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import Foundation
import CoreBluetooth

@MainActor
final class DeviceDetailViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var services: [CBService] = []
    @Published private(set) var characteristics: [CBCharacteristic] = []
    @Published private(set) var selectedService: CBService?
    @Published private(set) var selectedCharacteristic: CBCharacteristic?
    @Published private(set) var characteristicValue: Data?
    @Published private(set) var isDiscoveringCharacteristics = false
    @Published private(set) var isReadingValue = false
    @Published private(set) var connectionState: ConnectionState
    @Published var errorMessage: String?
    @Published var showingError = false
    
    // MARK: - Private Properties
    let bluetoothService: BLEManagerProtocol
    let device: PeripheralModel
        
    var viewState: DeviceDetailViewState {
        DeviceDetailViewState(
            device: device,
            services: services,
            characteristics: characteristics,
            selectedService: selectedService,
            selectedCharacteristic: selectedCharacteristic,
            characteristicValue: characteristicValue,
            isDiscoveringCharacteristics: isDiscoveringCharacteristics,
            isReadingValue: isReadingValue,
            connectionState: connectionState,
            errorMessage: errorMessage,
            showingError: showingError
        )
    }
    
    init(
        device: PeripheralModel,
        bluetoothService: BLEManagerProtocol
    ) {
        self.device = device
        self.bluetoothService = bluetoothService
        
        if bluetoothService.isConnected &&
           bluetoothService.connectedDevice?.peripheral.identifier == device.peripheral.identifier {
            self.connectionState = .connected
            loadExistingServices()
        } else {
            self.connectionState = device.isConnectable ? .disconnected : .notConnectable
        }
        
        Task { [weak self] in
            await self?.monitorConnectionState()
        }
        
        Task { [weak self] in
            await self?.monitorLoadingStateTimeout()
        }
    }
    
    @MainActor
    private func monitorConnectionState() async {
        for await _ in ticker(every: 2.0) {
            let isCurrentlyConnected =
            bluetoothService.isConnected &&
            bluetoothService.connectedDevice?.peripheral.identifier == device.peripheral.identifier
            
            if !isCurrentlyConnected && connectionState == .connected {
                connectionState = device.isConnectable ? .disconnected : .notConnectable
                services = []
                characteristics = []
            }
        }
    }
    
    @MainActor
    private func monitorLoadingStateTimeout() async {
        var loadingStartTime: Date?
        
        for await _ in ticker(every: 5.0) {
            if connectionState.isLoading {
                if loadingStartTime == nil {
                    loadingStartTime = Date()
                } else if let start = loadingStartTime {
                    let loadingDuration = Date().timeIntervalSince(start)
                    if loadingDuration > 15 {
                        connectionState = device.isConnectable ? .disconnected : .notConnectable
                        services = []
                        characteristics = []
                        loadingStartTime = nil
                        
                        handleError(BLEError.timeout)
                    }
                }
            } else {
                loadingStartTime = nil
            }
        }
    }
}

// MARK: - Public Methods
extension DeviceDetailViewModel {
    func connectToDevice() {
        guard connectionState.canConnect else { return }
        
        Task {
            do {
                await MainActor.run {
                    self.connectionState = .connecting
                }
                
                try await ConcurrencyTimeouts.withTimeout(10) {
                    try await self.bluetoothService.connect(to: self.device)
                }
                
                await discoverServices()
                
            } catch {
                await MainActor.run {
                    self.connectionState = .disconnected
                }
                handleError(error)
            }
        }
    }
    
    // MARK: - Private Methods
    func disconnectFromDevice() {
        guard connectionState.canDisconnect else { return }
        
        Task {
            await MainActor.run {
                self.connectionState = .disconnecting
            }
            
            await bluetoothService.disconnect()
            
            await MainActor.run {
                self.connectionState = .disconnected
                self.services = []
                self.characteristics = []
            }
        }
    }
    
    func discoverServices() async {
        guard bluetoothService.isConnected else {
            handleError(BLEError.noConnectedDevice)
            return
        }
        
        await MainActor.run {
            self.connectionState = .discoveringServices
        }
        
        do {
            let discoveredServices = try await ConcurrencyTimeouts.withTimeout(10.0) {
                try await self.bluetoothService.discoverServices()
            }
            
            await MainActor.run {
                self.services = discoveredServices
                self.connectionState = .interrogating
            }

            try? await Task.sleep(for: .milliseconds(500))
            
            await MainActor.run {
                self.connectionState = .connected
            }
        } catch {
            await MainActor.run {
                self.connectionState = .connected
            }
            handleError(error)
        }
    }
    
    func discoverCharacteristics(for service: CBService) {
        guard bluetoothService.isConnected else {
            handleError(BLEError.noConnectedDevice)
            return
        }
        
        Task {
            await MainActor.run {
                self.isDiscoveringCharacteristics = true
                self.selectedService = service
            }
            
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
                handleError(error)
            }
        }
    }
    
    func readValue(for characteristic: CBCharacteristic) {
        guard bluetoothService.isConnected else {
            handleError(BLEError.noConnectedDevice)
            return
        }
        
        Task {
            await MainActor.run {
                self.isReadingValue = true
                self.selectedCharacteristic = characteristic
            }
            
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
                handleError(error)
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
                handleError(error)
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
                handleError(error)
            }
        }
    }
}

// MARK: - Private Methods
private extension DeviceDetailViewModel {
    func ticker(every interval: TimeInterval) -> AsyncStream<Void> {
        AsyncStream { continuation in
            let task = Task {
                while !Task.isCancelled {
                    try? await Task.sleep(for: interval)
                    if Task.isCancelled { break }
                    continuation.yield(())
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
    func handleError(_ error: Error) {
        Task { @MainActor in
            self.errorMessage = BLEErrorMapper.userMessage(for: error)
            self.showingError = true
        }
    }
    
    func loadExistingServices() {
        if let connectedDevice = bluetoothService.connectedDevice,
           connectedDevice.peripheral.identifier == device.peripheral.identifier {
            self.services = connectedDevice.peripheral.services ?? []
        }
    }
}
