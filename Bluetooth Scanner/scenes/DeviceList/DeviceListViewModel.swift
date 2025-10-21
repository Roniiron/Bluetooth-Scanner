//
//  DeviceListViewModel.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import Foundation
import CoreBluetooth

@MainActor
final class DeviceListViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var devices: [PeripheralModel] = []
    @Published private(set) var isScanning = false
    @Published private(set) var bluetoothState: CBManagerState = .unknown
    @Published private(set) var loadingState: LoadingState = .initializing
    @Published var errorMessage: String?
    @Published var showingError = false
    @Published var isFilterEnabled = false
    @Published var minimumRSSI: Double = -100.0
    @Published var showingFilterPopup = false
    @Published private(set) var isClearingDevices = false
    
    // MARK: - Private Properties
    private let bluetoothService: BLEManagerProtocol
    private let filterService: DeviceFilterService
    private let clearDebouncer = Debouncer(delay: 0.3)
    private var scanningTask: Task<Void, Never>?
    private var hasAutoStarted = false
    private var hasCompletedInitialLoad = false
    private var pendingDevices: [PeripheralModel] = []
    private var updateTimerTask: Task<Void, Never>?
    private var observeDevicesTask: Task<Void, Never>?
    private var observeStateTask: Task<Void, Never>?
    private var initializationStartTime: Date?
    private var discoveredDeviceIDs = Set<UUID>() // Track logged devices to prevent spam!
    
    var viewState: DeviceListViewState {
        DeviceListViewState(
            devices: devices,
            isScanning: isScanning,
            bluetoothState: bluetoothState,
            loadingState: loadingState,
            errorMessage: errorMessage,
            showingError: showingError,
            isFilterEnabled: isFilterEnabled,
            minimumRSSI: minimumRSSI,
            showingFilterPopup: showingFilterPopup,
            isClearingDevices: isClearingDevices
        )
    }
    
    init(
        bluetoothService: BLEManagerProtocol,
        filterService: DeviceFilterService = DeviceFilterService()
    ) {
        self.bluetoothService = bluetoothService
        self.filterService = filterService
        
        BLELogger.logAppLaunch()
        initializationStartTime = Date()
        
        setupBluetoothService()
    }
    
    deinit {
        scanningTask?.cancel()
        updateTimerTask?.cancel()
        observeDevicesTask?.cancel()
        observeStateTask?.cancel()
    }
}

// MARK: - Public Methods
extension DeviceListViewModel {
    func startScanning() {
        guard !isScanning else { return }
        guard bluetoothState == .poweredOn else {
            BLELogger.logStateIssue(state: bluetoothState.stateDescription, reason: "Cannot start scanning")
            return
        }
        
        isScanning = true
        
        BLELogger.logScanStart(isAutoStart: false)
        hasAutoStarted = true
        loadingState = .scanning
        discoveredDeviceIDs.removeAll()
        
        scanningTask = Task {
            do {
                try await self.bluetoothService.startScanning()
            } catch {
                BLELogger.logScanError(error: error)
                handleError(error)
            }
        }
    }
    
    func stopScanning() {
        scanningTask?.cancel()
        scanningTask = nil
        
        BLELogger.logScanStop(reason: "User action")
        
        Task {
            await self.bluetoothService.stopScanning()
            await MainActor.run {
                self.loadingState = .scanningStopped
            }
        }
    }
    
    func clearDevices() {
        Task { @MainActor in
            guard !self.isClearingDevices else { return }
            self.isClearingDevices = true
            
            let deviceCount = self.devices.count
            
            await clearDebouncer.debounce {
                await MainActor.run {
                    self.devices.removeAll()
                    self.pendingDevices.removeAll()
                    self.discoveredDeviceIDs.removeAll()
                    self.isClearingDevices = false

                    if !self.isScanning {
                        self.loadingState = .idle
                    }
                }
                await self.bluetoothService.clearDevices()
                BLELogger.logDeviceListCleared(count: deviceCount)
            }
        }
    }
    
    func sortDevicesBySignalStrength() {
        devices = filterService.sortBySignalStrength(devices: devices)
    }
    
    func showFilterPopup() {
        showingFilterPopup = true
    }
    
    func updateFilter() {
        updateDeviceList()
    }
}

// MARK: - Private Methods
private extension DeviceListViewModel {
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
    func setupBluetoothService() {
        observeDiscoveredDevices()
        startUpdateTimer()
        observeBluetoothState()
    }
    
    func observeDiscoveredDevices() {
        observeDevicesTask = Task { [weak self] in
            guard let self else { return }
            for await discoveredDevices in self.bluetoothService.discoveredDevices {
                await MainActor.run {
                    self.pendingDevices = discoveredDevices
                }
            }
        }
    }
    
    func observeBluetoothState() {
        observeStateTask = Task { [weak self] in
            guard let self else { return }
            BLELogger.logInitializationStart()
            
            // Wait for Bluetooth state to stabilize
            try? await Task.sleep(for: 0.4)
            
            for await _ in ticker(every: 0.1) {
                await MainActor.run {
                    let previousState = self.bluetoothState
                    self.isScanning = self.bluetoothService.isScanning
                    self.bluetoothState = self.bluetoothService.bluetoothState
                    
                    self.handleBluetoothStateChange(from: previousState)
                }
                
                await attemptAutoStart()
                await completeInitializationIfNeeded()
            }
        }
    }
    
    func handleBluetoothStateChange(from previousState: CBManagerState) {
        if previousState != bluetoothState {
            BLELogger.logStateChange(from: previousState.stateDescription, to: bluetoothState.stateDescription)
        }
        
        if previousState == .poweredOn && bluetoothState != .poweredOn {
            stopScanning()
        }
        
        if bluetoothState == .poweredOff || bluetoothState == .unauthorized {
            devices.removeAll()
            pendingDevices.removeAll()
            
            if loadingState.isInitializing {
                loadingState = .idle
                hasCompletedInitialLoad = true
                hasAutoStarted = true
                
                if let startTime = initializationStartTime {
                    let duration = Date().timeIntervalSince(startTime)
                    BLELogger.logInitializationComplete(duration: duration)
                }
            } else if hasCompletedInitialLoad {
                loadingState = .idle
            }
        }
    }
    
    func completeInitializationIfNeeded() async {
        guard !hasCompletedInitialLoad, !hasAutoStarted else { return }
        
        let state = self.bluetoothService.bluetoothState
        
        if state == .poweredOff || state == .unauthorized || state == .unsupported {
            await MainActor.run {
                if self.loadingState.isInitializing {
                    self.loadingState = .idle
                    
                    if let startTime = self.initializationStartTime {
                        let duration = Date().timeIntervalSince(startTime)
                        BLELogger.logInitializationComplete(duration: duration)
                    }
                }
                self.hasCompletedInitialLoad = true
                self.hasAutoStarted = true
            }
        }
    }
    
    func attemptAutoStart() async {
        guard !hasAutoStarted,
              bluetoothService.bluetoothState == .poweredOn,
              !bluetoothService.isScanning else {
            return
        }
        
        hasAutoStarted = true
        
        // Start scanning immediately without showing idle state
        if self.bluetoothService.bluetoothState == .poweredOn && !self.bluetoothService.isScanning {
            do {
                BLELogger.logScanStart(isAutoStart: true)
                
                await MainActor.run {
                    self.discoveredDeviceIDs.removeAll()
                    self.loadingState = .scanning
                }
                try await self.bluetoothService.startScanning()
                
                await MainActor.run {
                    self.hasCompletedInitialLoad = true
                    
                    if let startTime = self.initializationStartTime {
                        let duration = Date().timeIntervalSince(startTime)
                        BLELogger.logInitializationComplete(duration: duration)
                    }
                }
            } catch {
                BLELogger.logScanError(error: error)
                await MainActor.run {
                    self.loadingState = .idle
                    self.hasCompletedInitialLoad = true
                }
            }
        }
    }
    
    func handleError(_ error: Error) {
        Task { @MainActor in
            self.errorMessage = BLEErrorMapper.userMessage(for: error)
            self.showingError = true
        }
    }
    
    func startUpdateTimer() {
        updateTimerTask?.cancel()
        
        updateTimerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: 1.0)
                
                await MainActor.run {
                    self.updateDeviceList()
                }
            }
        }
    }
    
    func updateDeviceList() {
        var updatedDevices = filterService.updateDeviceList(
            currentDevices: devices,
            newDevices: pendingDevices
        )
        
        if isFilterEnabled {
            updatedDevices = filterService.filterByRSSI(
                devices: updatedDevices,
                minimumRSSI: Int(minimumRSSI)
            )
        }
        
        // Logging only truly NEW devices (never seen before in this session)
        for device in updatedDevices {
            if !discoveredDeviceIDs.contains(device.id) {
                discoveredDeviceIDs.insert(device.id)
                BLELogger.logDeviceDiscovered(
                    name: device.name ?? "Unknown",
                    rssi: device.rssi,
                    uuid: device.id.uuidString
                )
            }
        }
        
        devices = updatedDevices
    }
}

// MARK: - CBManagerState Extension
extension CBManagerState {
    var stateDescription: String {
        switch self {
        case .unknown:
            return "Unknown"
        case .resetting:
            return "Resetting"
        case .unsupported:
            return "Unsupported"
        case .unauthorized:
            return "Unauthorized"
        case .poweredOff:
            return "Powered Off"
        case .poweredOn:
            return "Powered On"
        @unknown default:
            return "Unknown State"
        }
    }
}
