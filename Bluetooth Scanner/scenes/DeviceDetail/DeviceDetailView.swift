//
//  DeviceDetailView.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import SwiftUI
import CoreBluetooth

struct DeviceDetailView: View {
    @StateObject private var viewModel: DeviceDetailViewModel
    
    init(device: PeripheralModel, bleManager: BLEManager) {
        _viewModel = StateObject(wrappedValue: DeviceDetailViewModel(
            device: device,
            bluetoothService: bleManager
        ))
    }
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    deviceHeaderCard
                    
                    deviceInfoSection
                    
                    connectionButtonSection
                    
                    if viewModel.viewState.shouldShowServices {
                        servicesButton
                    }
                }
                .padding(16)
            }
            
            if viewModel.viewState.showConnectionStateOverlay {
                connectionStateOverlay
            }
        }
        .navigationTitle(L10n.Details.deviceDetails)
        .navigationBarTitleDisplayMode(.inline)
        .alert(L10n.Error.unknown, isPresented: $viewModel.showingError) {
            Button(L10n.Action.done) { }
        } message: {
            Text(viewModel.errorMessage ?? L10n.Error.unknown)
        }
    }
    
    // MARK: - Subviews
    private var deviceHeaderCard: some View {
        VStack(spacing: 16) {
            VStack(spacing: 12) {
                Image(systemName: "airpodspro")
                    .font(.system(size: 50))
                    .foregroundStyle(.blue)
                    .symbolEffect(.pulse.byLayer, options: .repeating)
                
                Text(viewModel.viewState.deviceName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 8)
            
            connectionStatusBadge
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var deviceInfoCard: some View {
        Text("View technical details about this Bluetooth device including signal strength, power levels, and manufacturer data.")
            .font(.caption)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 0)
            .padding(.vertical, 8)
            .background(Color.blue.opacity(0.05))
            .cornerRadius(8)
    }
    
    private var servicesCard: some View {
        Text("Explore available services and their characteristics to understand the device's capabilities.")
            .font(.caption)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 0)
            .padding(.vertical, 8)
            .background(Color.blue.opacity(0.05))
            .cornerRadius(8)
    }
    
    private var connectionStatusBadge: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            
            Text(viewModel.viewState.connectionStateText)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(statusColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(statusColor.opacity(0.1))
        .cornerRadius(20)
    }
    
    private var statusColor: Color {
        switch viewModel.viewState.connectionState {
        case .connected:
            return .green
        case .disconnected:
            return .gray
        case .connecting, .discoveringServices, .interrogating, .disconnecting:
            return .blue
        case .notConnectable:
            return .orange
        }
    }
    
    private var deviceInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(L10n.Details.deviceInfo)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            deviceInfoCard
            
            VStack(spacing: 0) {
                ExpandableInfoCell(
                    icon: "antenna.radiowaves.left.and.right",
                    label: L10n.Device.identifier,
                    value: viewModel.viewState.deviceIdentifier,
                    expandedContent: viewModel.viewState.deviceUUID
                )
                
                Divider().padding(.leading, 44)
                
                ExpandableInfoCell(
                    icon: "wifi",
                    label: L10n.Device.signalStrength,
                    value: viewModel.viewState.deviceRSSI,
                    expandedContent: "RSSI (Received Signal Strength Indicator) measures the power level of the received signal. Higher values (closer to 0) indicate stronger signal strength."
                )
                
                Divider().padding(.leading, 44)
                
                ExpandableInfoCell(
                    icon: viewModel.viewState.isConnectable ? "checkmark.circle.fill" : "xmark.circle.fill",
                    label: L10n.Device.connectable,
                    value: viewModel.viewState.isConnectableString,
                    expandedContent: viewModel.viewState.isConnectable ? 
                        "This device can accept incoming connections and supports GATT services." :
                        "This device broadcasts advertisement data only and cannot accept connections.",
                    valueColor: viewModel.viewState.isConnectable ? .green : .orange
                )
                
                if viewModel.viewState.txPowerLevel != L10n.Device.unknown {
                    Divider().padding(.leading, 44)
                    
                    ExpandableInfoCell(
                        icon: "bolt.fill",
                        label: L10n.Device.txPower,
                        value: viewModel.viewState.txPowerLevel,
                        expandedContent: "TX Power Level indicates the transmission power of the device's radio. This helps estimate the distance to the device."
                    )
                }
                
                if viewModel.viewState.manufacturerData != L10n.Details.noManufacturerData {
                    Divider().padding(.leading, 44)
                    
                    ExpandableInfoCell(
                        icon: "building.2.fill",
                        label: L10n.Device.manufacturerData,
                        value: viewModel.viewState.manufacturerData,
                        expandedContent: "Raw manufacturer-specific data included in the advertisement packet."
                    )
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }
    
    private var connectionButtonSection: some View {
        HStack {
            Spacer()
            
            Group {
                if viewModel.viewState.canConnect {
                    Button {
                        viewModel.connectToDevice()
                    } label: {
                        Text(L10n.Action.connect)
                            .font(.body.weight(.semibold))
                            .padding(.horizontal, 24)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .cornerRadius(10)
                } else if viewModel.viewState.canDisconnect {
                    Button {
                        viewModel.disconnectFromDevice()
                    } label: {
                        Text(L10n.Action.disconnect)
                            .font(.body.weight(.semibold))
                            .padding(.horizontal, 24)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                    .cornerRadius(10)
                }
            }
            
            Spacer()
        }
    }
    
    private var servicesButton: some View {
        VStack(spacing: 8) {
            HStack {
                Text(L10n.Details.services)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            servicesCard
            
            NavigationLink(destination: ServicesView(device: viewModel.device, bleManager: viewModel.bluetoothService)) {
                HStack(spacing: 12) {
                    Image(systemName: "server.rack")
                        .font(.title2)
                        .foregroundStyle(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(L10n.Details.viewServices)
                            .font(.body.weight(.medium))
                            .foregroundColor(.primary)
                        
                        Text(viewModel.viewState.servicesCountText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.secondary)
                }
                .padding(16)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            }
            .buttonStyle(.plain)
        }
    }
    
    private var connectionStateOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(1.5)
                    .tint(.white)
                
                Text(viewModel.viewState.connectionStateOverlayText)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray))
                    .shadow(radius: 20)
            )
        }
        .transition(.opacity)
    }
}
