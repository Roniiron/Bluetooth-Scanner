//
//  ServiceRowView.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import SwiftUI
import CoreBluetooth

struct ServiceRowView: View {
    let service: CBService
    let device: PeripheralModel
    let bleManager: BLEManagerProtocol
    let isDiscovering: Bool
    let characteristics: [CBCharacteristic]
    let characteristicValues: [CBUUID: String?]
    let onDiscoverCharacteristics: () -> Void
    let onReadCharacteristic: ((CBCharacteristic) -> Void)?
    let onWriteCharacteristic: ((CBCharacteristic) -> Void)?
    let onNotifyCharacteristic: ((CBCharacteristic) -> Void)?
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(serviceDisplayName)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Text("Service")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .textSelection(.enabled)
                }
                
                Spacer()
                
                if characteristics.isEmpty {
                    Button(action: onDiscoverCharacteristics) {
                        HStack(spacing: 4) {
                            if isDiscovering {
                                ProgressView()
                                    .scaleEffect(0.7)
                            } else {
                                Image(systemName: "magnifyingglass")
                                    .font(.caption2)
                            }
                            
                            Text(isDiscovering ? "Discovering..." : "Discover")
                                .font(.caption2)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                    }
                    .disabled(isDiscovering)
                } else {
                    Text("\(characteristics.count)")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
                    if !characteristics.isEmpty {
                        Divider()
                            .padding(.leading, 16)
                        
                        VStack(spacing: 0) {
                ForEach(Array(characteristics.enumerated()), id: \.element.uuid) { index, characteristic in
                    CompactCharacteristicRowView(
                        characteristic: characteristic,
                        value: characteristicValues[characteristic.uuid] ?? nil,
                        onRead: onReadCharacteristic.map { callback in { callback(characteristic) } },
                        onWrite: onWriteCharacteristic.map { callback in { callback(characteristic) } },
                        onNotify: onNotifyCharacteristic.map { callback in { callback(characteristic) } }
                    )
                                
                                if index < characteristics.count - 1 {
                                    Divider()
                                        .padding(.leading, 16)
                                }
                            }
                        }
                        .background(Color(.systemGray6).opacity(0.3))
                    }
        }
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Computed Properties
    private var serviceDisplayName: String {
        service.uuid.name ?? formatUUID(service.uuid.uuidString)
    }
    
    // MARK: - Helper
    private func formatUUID(_ uuid: String) -> String {
        if uuid.count == 36 && uuid.hasSuffix("-0000-1000-8000-00805F9B34FB") {
            let prefix = uuid.prefix(8)
            return "\(prefix)..."
        }
        return uuid
    }
}

// MARK: - Compact Characteristic Row View
struct CompactCharacteristicRowView: View {
    let characteristic: CBCharacteristic
    let value: String?
    let onRead: (() -> Void)?
    let onWrite: (() -> Void)?
    let onNotify: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 1) {
                Text(characteristicDisplayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                if let value = value, !value.isEmpty {
                    Text(value)
                        .font(.caption2)
                        .foregroundColor(.blue)
                        .textSelection(.enabled)
                } else {
                    Text(formatUUID(characteristic.uuid.uuidString))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .textSelection(.enabled)
                }
            }
            
            Spacer()
            
            HStack(spacing: 6) {
                if characteristic.properties.contains(.read), let onRead = onRead {
                    Button(action: onRead) {
                        Text("Read")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
                
                if characteristic.properties.contains(.write), let onWrite = onWrite {
                    Button(action: onWrite) {
                        Text("Write")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
                
                if characteristic.properties.contains(.notify), let onNotify = onNotify {
                    Button(action: onNotify) {
                        Text("Notify")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    // MARK: - Computed Properties
    private var characteristicDisplayName: String {
        characteristic.uuid.name ?? formatUUID(characteristic.uuid.uuidString)
    }
    
    private var characteristicProperties: String {
        var properties: [String] = []
        
        if characteristic.properties.contains(.read) {
            properties.append("Read")
        }
        if characteristic.properties.contains(.write) {
            properties.append("Write")
        }
        if characteristic.properties.contains(.notify) {
            properties.append("Notify")
        }
        return properties.joined(separator: ", ")
    }
    
    // MARK: - Helper
    private func formatUUID(_ uuid: String) -> String {
        if uuid.count == 36 && uuid.hasSuffix("-0000-1000-8000-00805F9B34FB") {
            let prefix = uuid.prefix(8)
            return "\(prefix)..."
        }
        return uuid
    }
}
