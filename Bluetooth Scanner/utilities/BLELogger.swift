//
//  BLELogger.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import Foundation
import os.log

final class BLELogger {
    // MARK: - Subsystem & Categories
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.bluetooth.scanner"
    
    enum Category: String {
        case lifecycle = "BLE.Lifecycle"
        case state = "BLE.State"
        case scanning = "BLE.Scanning"
        case discovery = "BLE.Discovery"
        case connection = "BLE.Connection"
        case performance = "BLE.Performance"
        case notifications = "BLE.Notifications"
    }
    
    // MARK: - Loggers
    private static let lifecycleLogger = Logger(subsystem: subsystem, category: Category.lifecycle.rawValue)
    private static let stateLogger = Logger(subsystem: subsystem, category: Category.state.rawValue)
    private static let scanningLogger = Logger(subsystem: subsystem, category: Category.scanning.rawValue)
    private static let discoveryLogger = Logger(subsystem: subsystem, category: Category.discovery.rawValue)
    private static let connectionLogger = Logger(subsystem: subsystem, category: Category.connection.rawValue)
    private static let performanceLogger = Logger(subsystem: subsystem, category: Category.performance.rawValue)
    private static let notificationsLogger = Logger(subsystem: subsystem, category: Category.notifications.rawValue)
    
    // MARK: - Public Logging Methods

    // MARK: Lifecycle
    static func logAppLaunch() {
        lifecycleLogger.info("App launched - Initializing BLE subsystem")
    }
    
    static func logInitializationStart() {
        lifecycleLogger.debug("BLE initialization started")
    }
    
    static func logInitializationComplete(duration: TimeInterval) {
        lifecycleLogger.info("BLE initialization complete (took \(String(format: "%.2f", duration))s)")
    }
    
    // MARK: State Changes
    static func logStateChange(from oldState: String, to newState: String) {
        stateLogger.info("Bluetooth state changed: \(oldState) → \(newState)")
    }
    
    static func logStateIssue(state: String, reason: String) {
        stateLogger.warning("⚠️ Bluetooth state issue: \(state) - \(reason)")
    }

    // MARK: Scanning
    static func logScanStart(isAutoStart: Bool = false) {
        let prefix = isAutoStart ? "Auto-start" : "Manual"
        scanningLogger.info("\(prefix) scanning initiated")
    }
    
    static func logScanStop(reason: String = "User action") {
        scanningLogger.info("Scanning stopped - \(reason)")
    }
    
    static func logScanError(error: Error) {
        scanningLogger.error("❌ Scan error: \(error.localizedDescription)")
    }
    
    // MARK: Device Discovery
    static func logDeviceDiscovered(name: String, rssi: Int, uuid: String) {
        discoveryLogger.info("New device: \(name) (RSSI: \(rssi) dB)")
    }
    
    static func logDeviceListCleared(count: Int) {
        discoveryLogger.info("Cleared \(count) device(s) from list")
    }
    
    // MARK: Connection
    static func logConnectionAttempt(deviceName: String) {
        connectionLogger.info("Attempting to connect to: \(deviceName)")
    }
    
    static func logConnectionSuccess(deviceName: String, duration: TimeInterval) {
        connectionLogger.info("✅ Connected to \(deviceName) (took \(String(format: "%.2f", duration))s)")
    }
    
    static func logConnectionFailure(deviceName: String, error: Error) {
        connectionLogger.error("❌ Connection failed: \(deviceName) - \(error.localizedDescription)")
    }
    
    static func logDisconnection(deviceName: String, reason: String) {
        connectionLogger.info("Disconnected from \(deviceName) - \(reason)")
    }
    
    // MARK: Performance
    static func logPerformanceMetric(operation: String, duration: TimeInterval) {
        performanceLogger.debug("\(operation) took \(String(format: "%.3f", duration))s")
    }
    
    static func logMemoryWarning() {
        performanceLogger.warning("⚠️ Memory warning received")
    }
}

// MARK: - Notifications
extension BLELogger {
    static func logNotificationSubscribe(uuid: String) {
        notificationsLogger.info("Subscribed to notifications: \(uuid)")
    }
    static func logNotificationUnsubscribe(uuid: String) {
        notificationsLogger.info("Unsubscribed from notifications: \(uuid)")
    }
}

