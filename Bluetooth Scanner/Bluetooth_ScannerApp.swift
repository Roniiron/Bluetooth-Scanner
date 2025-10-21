//
//  Bluetooth_ScannerApp.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import SwiftUI

@main
struct Bluetooth_ScannerApp: App {
    // Single instance of BLEManager for the entire app lifecycle
    @StateObject private var bleManager = BLEManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bleManager)
        }
    }
}
