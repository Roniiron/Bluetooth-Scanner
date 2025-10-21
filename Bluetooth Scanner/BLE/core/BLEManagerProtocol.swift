//
//  BLEManagerProtocol.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import CoreBluetooth

/// Main protocol that composes all BLE operation protocols
/// Provides a unified interface while maintaining separation of concerns internally
protocol BLEManagerProtocol:
    BLEScanningProtocol,
    BLEConnectionProtocol,
    BLEServiceDiscoveryProtocol,
    BLECharacteristicProtocol,
    BLEStateProtocol
{
    // MARK: Device Operations
    func readAdvertisementData(for device: PeripheralModel) async throws -> [String: Any]
    func clearDevices() async
    
    // MARK: Notification Operations
    func subscribeToNotifications(for characteristic: CBCharacteristic) async throws
    func unsubscribeFromNotifications(for characteristic: CBCharacteristic) async throws
    func isSubscribed(to characteristic: CBCharacteristic) -> Bool
    func toggleNotification(for characteristic: CBCharacteristic) async throws
}
