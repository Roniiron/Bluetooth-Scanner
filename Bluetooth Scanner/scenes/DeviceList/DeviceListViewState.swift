//
//  DeviceListViewState.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import Foundation
import CoreBluetooth

struct DeviceListViewState {
    // MARK: - Properties
    let devices: [PeripheralModel]
    let isScanning: Bool
    let bluetoothState: CBManagerState
    let loadingState: LoadingState
    let errorMessage: String?
    let showingError: Bool
    let isFilterEnabled: Bool
    let minimumRSSI: Double
    let showingFilterPopup: Bool
    let isClearingDevices: Bool
    
    var canStartScanning: Bool {
        bluetoothState == .poweredOn && !isScanning
    }
    
    var canStopScanning: Bool {
        isScanning
    }
    
    var bluetoothStateText: String {
        switch bluetoothState {
        case .poweredOn:
            return "Bluetooth is On"
        case .poweredOff:
            return "Bluetooth is Off"
        case .resetting:
            return "Bluetooth is Resetting"
        case .unauthorized:
            return "Bluetooth Unauthorized"
        case .unsupported:
            return "Bluetooth Unsupported"
        case .unknown:
            return "Bluetooth State Unknown"
        @unknown default:
            return "Unknown State"
        }
    }
    
    var bluetoothIconColor: BluetoothIconColor {
        bluetoothState == .poweredOn ? .green : .red
    }
    
    var deviceCountText: String {
        switch bluetoothState {
        case .poweredOff, .unauthorized:
            return ""
        case .poweredOn:
            let count = devices.count
            return count == 1 ? "1 device found" : "\(count) devices found"
        default:
            return ""
        }
    }
    
    var scanningStatusText: String {
        isScanning ? L10n.App.scanningStatus : L10n.App.notScanning
    }
    
    var filterStatusText: String? {
        guard isFilterEnabled else { return nil }
        let bars = SignalStrengthCalculator.getSignalBars(for: Int(minimumRSSI))
        return L10n.Filter.statusFormat(Int(minimumRSSI), bars)
    }
    
    var emptyState: EmptyStateConfiguration {
        if loadingState.isInitializing {
            return .initializing
        } else if isScanning && devices.isEmpty {
            return .scanning
        } else if bluetoothState != .poweredOn {
            return .bluetoothIssue(state: bluetoothState)
        } else if devices.isEmpty && loadingState.isIdle {
            return .readyToScan
        } else if devices.isEmpty {
            return .noDevices
        } else {
            return .noDevices  // Fallback
        }
    }
    
    var shouldShowEmptyState: Bool {
        devices.isEmpty
    }
    
    var shouldShowClearButton: Bool {
        !devices.isEmpty && !isClearingDevices
    }
    
    var pullToRefreshHint: String {
        isScanning ? L10n.Message.pullToRefreshCancel : L10n.Message.pullToRefreshScan
    }
}

// MARK: - Supporting Types
enum BluetoothIconColor {
    case green, red
}

enum EmptyStateConfiguration {
    case initializing
    case readyToScan
    case scanning
    case bluetoothIssue(state: CBManagerState)
    case noDevices
    
    var title: String {
        switch self {
        case .initializing:
            return ""
        case .readyToScan:
            return L10n.App.readyToScan
        case .scanning:
            return L10n.App.scanning
        case .bluetoothIssue(let state):
            switch state {
            case .poweredOff:
                return L10n.Bluetooth.poweredOff
            case .unauthorized:
                return L10n.Bluetooth.unauthorized
            case .unsupported:
                return L10n.Bluetooth.unsupported
            case .resetting:
                return L10n.Bluetooth.resetting
            case .unknown:
                return L10n.Bluetooth.unknown
            default:
                return L10n.App.noDevicesFound
            }
        case .noDevices:
            return L10n.App.noDevicesFound
        }
    }
    
    var message: String {
        switch self {
        case .initializing:
            return ""
        case .readyToScan:
            return L10n.Message.readyToScan
        case .scanning:
            return L10n.Message.scanning
        case .bluetoothIssue(let state):
            switch state {
            case .poweredOff:
                return L10n.Message.bluetoothOff
            case .unauthorized:
                return L10n.Message.bluetoothUnauthorized
            case .unsupported:
                return L10n.Message.bluetoothUnsupported
            case .resetting:
                return L10n.Message.bluetoothResetting
            case .unknown:
                return L10n.Message.bluetoothUnknown
            default:
                return L10n.Message.noDevicesScan
            }
        case .noDevices:
            return L10n.Message.noDevicesScan
        }
    }
    
    var actionButtonTitle: String? {
        switch self {
        case .bluetoothIssue(let state):
            switch state {
            case .unauthorized:
                return L10n.Action.openSettings
            case .poweredOff:
                return L10n.Action.enableBluetooth
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    var showProgressIndicator: Bool {
        switch self {
        case .initializing, .scanning:
            return true
        default:
            return false
        }
    }
    
    var showBluetoothIcon: Bool {
        if case .bluetoothIssue = self {
            return true
        }
        return false
    }
    
    var showContent: Bool {
        if case .initializing = self {
            return false
        }
        return true
    }
}

