//
//  BLEScanningService.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import Foundation
import CoreBluetooth

/// Service responsible for BLE device scanning operations
protocol BLEScanningServiceProtocol: BLEScanningProtocol {
    func handleDiscoveredDevice(
        peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi: NSNumber
    )
    func handleScanStopped()
}

final class BLEScanningService: BLEScanningServiceProtocol {
    // MARK: - Properties
    private let centralManager: CBCentralManager
    private var devices: [UUID: PeripheralModel] = [:]
    private var devicesStream: AsyncStream<[PeripheralModel]>.Continuation?
    
    private(set) var isScanning = false
    
    init(centralManager: CBCentralManager) {
        self.centralManager = centralManager
    }
}

// MARK: - Public
extension BLEScanningService {
    func handleDiscoveredDevice(
        peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi: NSNumber
    ) {
        let device = PeripheralModel(
            peripheral: peripheral,
            rssi: rssi.intValue,
            advertisementData: advertisementData
        )
        
        devices[peripheral.identifier] = device
        devicesStream?.yield(Array(devices.values))
    }
    
    func handleScanStopped() {
        isScanning = false
    }
}

// MARK: - BLEScanningProtocol
extension BLEScanningService: BLEScanningProtocol {
    var discoveredDevices: AsyncStream<[PeripheralModel]> {
        AsyncStream { continuation in
            self.devicesStream = continuation
            continuation.yield(Array(devices.values))
        }
    }
    
    func startScanning() async throws {
        guard !isScanning else { return }
        
        devices.removeAll()
        isScanning = true
        
        centralManager.scanForPeripherals(
            withServices: nil,
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: true]
        )
    }
    
    func stopScanning() async {
        guard isScanning else { return }
        
        centralManager.stopScan()
        isScanning = false
    }
    
    func clearDiscoveredDevices() async {
        devices.removeAll()
        devicesStream?.yield([])
    }
}

