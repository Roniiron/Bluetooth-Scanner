//
//  ContentView.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var bleManager: BLEManager
    
    var body: some View {
        DeviceListView(bleManager: bleManager)
    }
}

#Preview {
    ContentView()
        .environmentObject(BLEManager())
}
