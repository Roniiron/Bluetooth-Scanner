//
//  ServicesView.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import SwiftUI
import CoreBluetooth

struct ServicesView: View {
    @StateObject private var viewModel: ServicesViewModel
    @State private var showingWriteAlert = false
    @State private var selectedCharacteristic: CBCharacteristic?
    @State private var writeDataText = ""
    
    init(device: PeripheralModel, bleManager: BLEManagerProtocol) {
        _viewModel = StateObject(wrappedValue: ServicesViewModel(
            device: device,
            bluetoothService: bleManager
        ))
    }
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            if viewModel.viewState.shouldShowEmptyState {
                emptyStateView
            } else {
                servicesContent
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .alert(L10n.Error.unknown, isPresented: $viewModel.showingError) {
            Button(L10n.Action.done) { }
        } message: {
            Text(viewModel.errorMessage ?? L10n.Error.unknown)
        }
        .alert("Write Value", isPresented: $showingWriteAlert) {
            TextField("Enter hex data (e.g., 48656C6C6F)", text: $writeDataText)
            Button("Write") {
                if let characteristic = selectedCharacteristic {
                    Task {
                        await writeToCharacteristic(characteristic)
                    }
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enter hex data to write to this characteristic")
        }
        .task {
            await viewModel.loadServices()
        }
    }
    
    private func writeToCharacteristic(_ characteristic: CBCharacteristic) async {
        guard !writeDataText.isEmpty else { return }
        
        guard let data = Data(hexString: writeDataText) else {
            print("Invalid hex string: \(writeDataText)")
            return
        }
        
        await viewModel.writeCharacteristic(characteristic, data: data)
    }
    
    // MARK: - Subviews
    private var servicesContent: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                deviceInfoHeader
                
                if viewModel.viewState.hasServices {
                    servicesList
                }
            }
            .padding(16)
        }
    }
    
    private var deviceInfoHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: "airpodspro")
                .font(.system(size: 40))
                .foregroundStyle(.blue)
                .symbolEffect(.pulse.byLayer, options: .repeating)
            
            Text(viewModel.device.displayName)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            // Connection Status
            HStack(spacing: 8) {
                Circle()
                    .fill(.green)
                    .frame(width: 8, height: 8)
                
                Text(L10n.Device.connected)
                    .font(.subheadline)
                    .foregroundColor(.green)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(.green.opacity(0.1))
            .cornerRadius(16)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var servicesInfoCard: some View {
        Text("Services define the device's capabilities and contain characteristics that hold specific data. Each service groups related functionality, while characteristics store the actual values you can read or write.")
            .font(.caption)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 0)
            .padding(.vertical, 8)
            .background(Color.blue.opacity(0.05))
            .cornerRadius(8)
    }
    
    
    private var servicesList: some View {
        LazyVStack(spacing: 16) {
            servicesInfoCard
            
                ForEach(viewModel.viewState.services, id: \.uuid) { service in
                    ServiceRowView(
                        service: service,
                        device: viewModel.device,
                        bleManager: viewModel.bluetoothService,
                        isDiscovering: viewModel.viewState.isServiceDiscovering(service),
                        characteristics: viewModel.viewState.characteristics(for: service),
                        characteristicValues: Dictionary(uniqueKeysWithValues: viewModel.viewState.characteristics(for: service).map {
                            ($0.uuid, viewModel.viewState.formattedValue(for: $0))
                        }),
                        onDiscoverCharacteristics: {
                            Task {
                                await viewModel.discoverCharacteristics(for: service)
                            }
                        },
                        onReadCharacteristic: { characteristic in
                            Task {
                                await viewModel.readCharacteristic(characteristic)
                            }
                        },
                        onWriteCharacteristic: { characteristic in
                            selectedCharacteristic = characteristic
                            writeDataText = ""
                            showingWriteAlert = true
                        },
                        onNotifyCharacteristic: { characteristic in
                            Task {
                                await viewModel.toggleNotification(characteristic)
                            }
                        }
                    )
                }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "puzzlepiece.extension")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            VStack(spacing: 8) {
                Text(L10n.Details.noServicesDiscovered)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(L10n.Details.noServicesDiscoveredDescription)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
}
