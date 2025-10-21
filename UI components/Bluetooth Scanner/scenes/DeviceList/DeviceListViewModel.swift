//
//  ContentView.swift
//  Bluetooth Scanner
//
//  Created by Roni on 13. 10. 2025..
//

import Foundation
import CoreBluetooth

// MARK: - DeviceListViewModel

@MainActor
final class DeviceListViewModel: ObservableObject {
    
    // MARK: Published Properties
    
    @Published private(set) var devices: [PeripheralModel] = []
    @Published private(set) var isScanning = false
    @Published private(set) var bluetoothState: CBManagerState = .unknown
    @Published var showingError = false
    @Published var errorMessage: String?
    @Published var isFilterEnabled = false
    @Published var minimumRSSI: Double = -100.0
    @Published var showingFilterPopup = false
    
    // MARK: Private Properties
    
    private let bleManager: BLEManagerProtocol
    private var pendingDevices: [PeripheralModel] = []
    private var scanTask: Task<Void, Never>?
    private var updateTask: Task<Void, Never>?
    private var stateTask: Task<Void, Never>?
    private var hasAutoStarted = false
    
    // MARK: Constants
    
    private enum Config {
        static let updateInterval: UInt64 = 1_000_000_000 // 1 second
        static let stateCheckInterval: UInt64 = 100_000_000 // 0.1 seconds
        static let autoStartDelay: UInt64 = 1_000_000_000 // 1 second
    }
    
    // MARK: Lifecycle
    
    init(bleManager: BLEManagerProtocol = BLEManager()) {
        self.bleManager = bleManager
        setupObservers()
    }
    
    deinit {
        cancelAllTasks()
    }
    
    // MARK: Public Methods
    
    func startScanning() {
        guard canStartScanning else { return }
        
        hasAutoStarted = true
        devices.removeAll()
        pendingDevices.removeAll()
        
        scanTask = Task {
            do {
                try await bleManager.startScanning()
            } catch {
                await handleError(error)
            }
        }
    }
    
    func stopScanning() {
        scanTask?.cancel()
        scanTask = nil
        
        Task {
            await bleManager.stopScanning()
        }
    }
    
    func clearDevices() {
        devices.removeAll()
        pendingDevices.removeAll()
        
        Task {
            await bleManager.clearDevices()
        }
    }
    
    func sortDevicesBySignalStrength() {
        devices.sort { $0.rssi > $1.rssi }
    }
    
    func toggleFilterPopup() {
        showingFilterPopup.toggle()
    }
    
    func updateFilter() {
        updateDeviceList()
    }
    
    func signalBars(for rssi: Int) -> Int {
        switch rssi {
        case -42...Int.max: return 5
        case -54...(-42): return 4
        case -66...(-54): return 3
        case -79...(-66): return 2
        case -90...(-79): return 1
        default: return 0
        }
    }
}

// MARK: - Computed Properties

extension DeviceListViewModel {
    
    var canStartScanning: Bool {
        bluetoothState == .poweredOn && !isScanning
    }
    
    var canStopScanning: Bool {
        isScanning
    }
    
    var bluetoothStateText: String {
        switch bluetoothState {
        case .poweredOn: return "Bluetooth is On"
        case .poweredOff: return "Bluetooth is Off"
        case .resetting: return "Bluetooth is Resetting"
        case .unauthorized: return "Bluetooth Unauthorized"
        case .unsupported: return "Bluetooth Unsupported"
        case .unknown: return "Bluetooth State Unknown"
        @unknown default: return "Unknown State"
        }
    }
    
    var deviceCountText: String {
        guard bluetoothState == .poweredOn else { return "" }
        return devices.count == 1 ? "1 device found" : "\(devices.count) devices found"
    }
    
    var filterStatusText: String {
        "Filtered: ≥\(Int(minimumRSSI)) dB (\(signalBars(for: Int(minimumRSSI))) bars)"
    }
}

// MARK: - Private Methods

private extension DeviceListViewModel {
    
    func setupObservers() {
        observeDeviceDiscovery()
        observeBluetoothState()
        startUpdateTimer()
    }
    
    func observeDeviceDiscovery() {
        Task {
            for await discovered in bleManager.discoveredDevices {
                await MainActor.run {
                    self.pendingDevices = discovered
                }
            }
        }
    }
    
    func observeBluetoothState() {
        stateTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: Config.stateCheckInterval)
                
                await MainActor.run {
                    updateState()
                }
            }
        }
    }
    
    func updateState() {
        let previousState = bluetoothState
        isScanning = bleManager.isScanning
        bluetoothState = bleManager.bluetoothState
        
        handleStateChange(from: previousState)
        handleAutoStart()
    }
    
    func handleStateChange(from previousState: CBManagerState) {
        // Stop scanning if Bluetooth becomes unavailable
        if previousState == .poweredOn && bluetoothState != .poweredOn {
            stopScanning()
        }
        
        // Clear devices if Bluetooth is off or unauthorized
        if bluetoothState == .poweredOff || bluetoothState == .unauthorized {
            devices.removeAll()
            pendingDevices.removeAll()
        }
    }
    
    func handleAutoStart() {
        guard !hasAutoStarted,
              bluetoothState == .poweredOn,
              !bleManager.isScanning else { return }
        
        hasAutoStarted = true
        
        Task {
            try? await Task.sleep(nanoseconds: Config.autoStartDelay)
            
            if bleManager.bluetoothState == .poweredOn && !bleManager.isScanning {
                try? await bleManager.startScanning()
            }
        }
    }
    
    func startUpdateTimer() {
        updateTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: Config.updateInterval)
                
                await MainActor.run {
                    updateDeviceList()
                }
            }
        }
    }
    
    func updateDeviceList() {
        let currentIds = Set(devices.map(\.id))
        let newDevices = pendingDevices.filter { !currentIds.contains($0.id) }
        
        // Add new devices
        devices.append(contentsOf: newDevices)
        
        // Update existing devices
        for i in devices.indices {
            if let updated = pendingDevices.first(where: { $0.id == devices[i].id }) {
                devices[i] = updated
            }
        }
        
        // Apply filter
        if isFilterEnabled {
            devices = devices.filter { $0.rssi >= Int(minimumRSSI) }
        }
    }
    
    func handleError(_ error: Error) {
        Task { @MainActor in
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
    
    func cancelAllTasks() {
        scanTask?.cancel()
        updateTask?.cancel()
        stateTask?.cancel()
    }
}
