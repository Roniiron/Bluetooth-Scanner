//
//  BLENotificationService.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import Foundation
import CoreBluetooth

/// Service responsible for handling notification subscriptions
protocol BLENotificationServiceProtocol {
    var subscribedCharacteristics: Set<CBUUID> { get }
    var notificationStates: [CBUUID: Bool] { get }
    func subscribeToNotifications(for characteristic: CBCharacteristic) async throws
    func unsubscribeFromNotifications(for characteristic: CBCharacteristic) async throws
    func isSubscribed(to characteristic: CBCharacteristic) -> Bool
    func toggleNotification(for characteristic: CBCharacteristic) async throws
    func handleNotificationStateChanged(error: Error?)
}

final class BLENotificationService: BLENotificationServiceProtocol {
    
    // MARK: - Private Properties
    private let connectionService: BLEConnectionServiceProtocol
    private var notificationContinuation: CheckedContinuation<Void, Error>?
    
    // MARK: - Published Properties
    @Published private(set) var subscribedCharacteristics: Set<CBUUID> = []
    @Published private(set) var notificationStates: [CBUUID: Bool] = [:]
    
    // MARK: - Initialization
    init(connectionService: BLEConnectionServiceProtocol) {
        self.connectionService = connectionService
    }
}

// MARK: - Public Methods
extension BLENotificationService {
    
    /// Subscribe to notifications for a characteristic
    func subscribeToNotifications(for characteristic: CBCharacteristic) async throws {
        guard characteristic.properties.contains(.notify) || characteristic.properties.contains(.indicate) else {
            throw BLEError.invalidOperation("Characteristic does not support notifications")
        }
        guard let peripheral = connectionService.connectedDevice?.peripheral else {
            throw BLEError.noConnectedDevice
        }
        
        BLELogger.logNotificationSubscribe(uuid: characteristic.uuid.uuidString)
        try await ConcurrencyTimeouts.withTimeout(BLEConstants.Timeout.operation) {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                self.notificationContinuation = continuation
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
        
        subscribedCharacteristics.insert(characteristic.uuid)
        notificationStates[characteristic.uuid] = true
    }
    
    /// Unsubscribe from notifications for a characteristic
    func unsubscribeFromNotifications(for characteristic: CBCharacteristic) async throws {
        guard let peripheral = connectionService.connectedDevice?.peripheral else {
            throw BLEError.noConnectedDevice
        }
        
        BLELogger.logNotificationUnsubscribe(uuid: characteristic.uuid.uuidString)
        try await ConcurrencyTimeouts.withTimeout(BLEConstants.Timeout.operation) {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                self.notificationContinuation = continuation
                peripheral.setNotifyValue(false, for: characteristic)
            }
        }
        
        subscribedCharacteristics.remove(characteristic.uuid)
        notificationStates[characteristic.uuid] = false
    }
    
    /// Check if currently subscribed to a characteristic
    func isSubscribed(to characteristic: CBCharacteristic) -> Bool {
        return subscribedCharacteristics.contains(characteristic.uuid)
    }
    
    /// Toggle notification subscription for a characteristic
    func toggleNotification(for characteristic: CBCharacteristic) async throws {
        if isSubscribed(to: characteristic) {
            try await unsubscribeFromNotifications(for: characteristic)
        } else {
            try await subscribeToNotifications(for: characteristic)
        }
    }
    
    /// Called by CBPeripheralDelegate to confirm notify state changes
    func handleNotificationStateChanged(error: Error?) {
        if let error = error {
            notificationContinuation?.resume(throwing: BLEError.notificationFailed(error))
        } else {
            notificationContinuation?.resume()
        }
        notificationContinuation = nil
    }
}
