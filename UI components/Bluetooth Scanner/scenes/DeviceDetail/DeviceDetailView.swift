//
//  DeviceDetailView.swift
//  Bluetooth Scanner
//
//  Created by Roni on 13. 10. 2025..
//

import SwiftUI
import CoreBluetooth

/// Detailed view for inspecting a specific Bluetooth device
struct DeviceDetailView: View {
    
    @StateObject private var viewModel: DeviceDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(device: PeripheralModel) {
        self._viewModel = StateObject(wrappedValue: DeviceDetailViewModel(device: device))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Device Info Section
                    deviceInfoSection
                    
                    // Advertisement Data Section
                    advertisementDataSection
                    
                    // Services Section
                    servicesSection
                    
                    // Characteristics Section
                    if !viewModel.characteristics.isEmpty {
                        characteristicsSection
                    }
                }
                .padding()
            }
            .navigationTitle(viewModel.deviceName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.isConnectable && !viewModel.isConnected {
                        Button("Connect") {
                            viewModel.connectToDevice()
                        }
                        .buttonStyle(.borderedProminent)
                    } else if viewModel.isConnected {
                        Button("Disconnect") {
                            viewModel.disconnectFromDevice()
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            .alert("Error", isPresented: $viewModel.showingError) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage ?? "Unknown error")
            }
        }
    }
    
    // MARK: - Device Info Section
    
    private var deviceInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Device Information")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                InfoRow(label: "Name", value: viewModel.deviceName)
                InfoRow(label: "RSSI", value: viewModel.deviceRSSI)
                InfoRow(label: "Connectable", value: viewModel.isConnectableString)
                InfoRow(label: "TX Power", value: viewModel.txPowerLevel)
                InfoRow(label: "Manufacturer Data", value: viewModel.manufacturerData)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
    
    // MARK: - Advertisement Data Section
    
    private var advertisementDataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Advertisement Data")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                if !viewModel.serviceUUIDs.isEmpty {
                    InfoRow(label: "Service UUIDs", value: viewModel.serviceUUIDs.joined(separator: ", "))
                }
                
                Text("Raw Data:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(viewModel.advertisementData)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
        }
    }
    
    // MARK: - Services Section
    
    private var servicesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Services")
                    .font(.headline)
                
                Spacer()
                
                if viewModel.isDiscoveringServices {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            
            if viewModel.services.isEmpty && !viewModel.isDiscoveringServices {
                Text("No services discovered")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.services, id: \.uuid) { service in
                        ServiceRowView(
                            service: service,
                            onDiscoverCharacteristics: {
                                viewModel.discoverCharacteristics(for: service)
                            },
                            isDiscovering: viewModel.isDiscoveringCharacteristics && viewModel.selectedService == service
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Characteristics Section
    
    private var characteristicsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Characteristics")
                .font(.headline)
            
            LazyVStack(spacing: 8) {
                ForEach(viewModel.characteristics, id: \.uuid) { characteristic in
                    CharacteristicRowView(
                        characteristic: characteristic,
                        onReadValue: {
                            viewModel.readValue(for: characteristic)
                        },
                        onSetNotification: { enabled in
                            viewModel.setNotification(enabled, for: characteristic)
                        },
                        value: viewModel.characteristicValue,
                        isReading: viewModel.isReadingValue && viewModel.selectedCharacteristic == characteristic
                    )
                }
            }
        }
    }
}

// MARK: - Info Row View


// MARK: - Service Row View

struct ServiceRowView: View {
    let service: CBService
    let onDiscoverCharacteristics: () -> Void
    let isDiscovering: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Service")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(service.uuid.uuidString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("Discover Characteristics") {
                    onDiscoverCharacteristics()
                }
                .buttonStyle(.bordered)
                .disabled(isDiscovering)
                
                if isDiscovering {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            
            if let characteristics = service.characteristics, !characteristics.isEmpty {
                Text("\(characteristics.count) characteristics")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Characteristic Row View

struct CharacteristicRowView: View {
    let characteristic: CBCharacteristic
    let onReadValue: () -> Void
    let onSetNotification: (Bool) -> Void
    let value: Data?
    let isReading: Bool
    
    private var properties: [String] {
        var props: [String] = []
        if characteristic.properties.contains(.read) { props.append("Read") }
        if characteristic.properties.contains(.write) { props.append("Write") }
        if characteristic.properties.contains(.notify) { props.append("Notify") }
        if characteristic.properties.contains(.indicate) { props.append("Indicate") }
        return props
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Characteristic")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(characteristic.uuid.uuidString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(properties.joined(separator: ", "))
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Button("Read Value") {
                        onReadValue()
                    }
                    .buttonStyle(.bordered)
                    .disabled(isReading || !characteristic.properties.contains(.read))
                    
                    if characteristic.properties.contains(.notify) {
                        Button("Toggle Notify") {
                            onSetNotification(true)
                        }
                        .buttonStyle(.bordered)
                        .font(.caption)
                    }
                }
                
                if isReading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            
            if let value = value {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Value:")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    Text(value.map { String(format: "%02X", $0) }.joined(separator: " "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(4)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Preview

struct DeviceDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let mockDevice = PeripheralModel(
            peripheral: CBPeripheral(),
            rssi: -50,
            advertisementData: [:]
        )
        DeviceDetailView(device: mockDevice)
    }
}
