//
//  SettingsNavigator.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import UIKit
import CoreBluetooth

final class SettingsNavigator {
    func openSettings(for bluetoothState: CBManagerState) {
        switch bluetoothState {
        case .unauthorized:
            openAppSettings()
        case .poweredOff:
            showBluetoothEnableAlert()
        default:
            openAppSettings()
        }
    }
    
    // MARK: - Private
    private func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(settingsUrl)
    }
    
    private func showBluetoothEnableAlert() {
        let alert = UIAlertController(
            title: "Bluetooth is Off",
            message: "To scan for devices, please enable Bluetooth:\n\n• Swipe down from top-right corner\n• Tap the Bluetooth icon\n• Or go to Settings > Bluetooth",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        // Present the alert
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            return
        }
        
        rootViewController.present(alert, animated: true)
    }
}

