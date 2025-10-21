//
//  CharacteristicRowView.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import SwiftUI
import CoreBluetooth

struct CharacteristicRowView: View {
    let characteristic: CBCharacteristic
    let onReadValue: () -> Void
    let onSetNotification: (Bool) -> Void
    let value: Data?
    let isReading: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    Image(systemName: "square.grid.3x3.fill")
                        .font(.title3)
                        .foregroundStyle(.purple.gradient)
                        .frame(width: 36, height: 36)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(8)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(L10n.Details.characteristicUuid)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(formatUUID(characteristic.uuid.uuidString))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .textSelection(.enabled)
                    }
                    
                    Spacer()
                    
                    if isReading {
                        ProgressView()
                            .scaleEffect(0.9)
                    }
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(propertiesArray, id: \.self) { property in
                            Text(property)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.purple)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.purple.opacity(0.1))
                                .cornerRadius(6)
                        }
                    }
                }
                
                HStack(spacing: 8) {
                    if CharacteristicPropertyFormatter.isReadable(characteristic.properties) {
                        Button {
                            onReadValue()
                        } label: {
                            Label(L10n.Action.read, systemImage: "doc.text")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(.blue)
                        .disabled(isReading)
                    }
                    
                    if CharacteristicPropertyFormatter.supportsNotifications(characteristic.properties) {
                        Button {
                            onSetNotification(true)
                        } label: {
                            Label(L10n.Action.notify, systemImage: "bell")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(.orange)
                    }
                }
                
                if let value = value {
                    valueDisplay(value)
                }
            }
            .padding(16)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Subviews
    private func valueDisplay(_ data: Data) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "doc.plaintext")
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Text(L10n.Details.currentValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                Text(DataValueFormatter.formatAsHex(data))
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.primary)
                    .padding(12)
                    .textSelection(.enabled)
            }
            .background(Color(.systemGray6).opacity(0.5))
            .cornerRadius(8)
        }
        .padding(12)
        .background(Color.blue.opacity(0.05))
        .cornerRadius(10)
    }
    
    private var propertiesText: String {
        CharacteristicPropertyFormatter.formatPropertiesString(characteristic.properties)
    }
    
    private var propertiesArray: [String] {
        propertiesText.components(separatedBy: ", ")
    }
    
    private func formatUUID(_ uuid: String) -> String {
        if uuid.count == 36 && uuid.hasSuffix("-0000-1000-8000-00805F9B34FB") {
            let prefix = uuid.prefix(8)
            return "\(prefix)..."
        }
        return uuid
    }
}

