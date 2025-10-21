//
//  SharedComponents.swift
//  Bluetooth Scanner
//
//  Created by Roni on 13. 10. 2025..
//

import SwiftUI

// MARK: - Info Row

struct InfoRow: View {
    let label: String
    let value: String
    let isSmallFont: Bool
    
    init(label: String, value: String, isSmallFont: Bool = false) {
        self.label = label
        self.value = value
        self.isSmallFont = isSmallFont
    }
    
    var body: some View {
        HStack {
            Text(label)
                .font(isSmallFont ? .caption2 : .caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(isSmallFont ? .caption2 : .caption)
                .foregroundColor(.primary)
                .lineLimit(nil)
            
            Spacer()
        }
    }
}

// MARK: - Signal Strength Icon

struct SignalStrengthIcon: View {
    let rssi: Int
    
    var body: some View {
        Image(systemName: wifiIconName)
            .foregroundColor(signalColor)
            .font(.system(size: 12))
    }
    
    private var signalColor: Color {
        switch rssi {
        case -50...0:
            return .green
        case -70..<(-50):
            return .yellow
        case -90..<(-70):
            return .orange
        default:
            return .red
        }
    }
    
    private var wifiIconName: String {
        switch rssi {
        case -50...0:
            return "wifi"
        case -60..<(-50):
            return "wifi"
        case -70..<(-60):
            return "wifi"
        case -80..<(-70):
            return "wifi"
        case -90..<(-80):
            return "wifi"
        default:
            return "wifi.slash"
        }
    }
}
