//
//  DeviceListHeaderView.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import SwiftUI

struct DeviceListHeaderView: View {
    let viewState: DeviceListViewState
    let onStartScanning: () -> Void
    let onStopScanning: () -> Void
    let onSortDevices: () -> Void
    let onShowFilter: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            statusSection
            
            if !viewState.deviceCountText.isEmpty || viewState.filterStatusText != nil {
                infoSection
            }
            
            controlsSection
        }
        .background(Color(.systemBackground))
    }
    
    // MARK: - Status Section
    
    private var statusSection: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(viewState.bluetoothIconColor == .green ? Color.green : Color.red)
                .frame(width: 8, height: 8)
            
            Text(viewState.bluetoothStateText)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            HStack(spacing: 6) {
                ProgressView()
                    .scaleEffect(0.7)
                    .frame(width: 14, height: 14)
                
                Text(L10n.App.scanningStatus)
                    .font(.caption)
                    .foregroundColor(.blue)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.blue.opacity(viewState.isScanning ? 0.1 : 0))
            .cornerRadius(12)
            .opacity(viewState.isScanning ? 1.0 : 0)
            .animation(.easeInOut(duration: 0.2), value: viewState.isScanning)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemGray6).opacity(0.5))
    }
    
    // MARK: - Info Section
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            if !viewState.deviceCountText.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Text(viewState.deviceCountText)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
            
            if let filterText = viewState.filterStatusText {
                HStack(spacing: 6) {
                    Image(systemName: "line.3.horizontal.decrease.circle.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    Text(filterText)
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    // MARK: - Controls Section
    private var controlsSection: some View {
        HStack(spacing: 12) {
            mainActionButton
            
            Spacer()
            
            secondaryActions
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemGray6).opacity(0.3))
    }
    
    private var mainActionButton: some View {
        Group {
            if viewState.canStartScanning {
                Button(action: onStartScanning) {
                    Label(L10n.Action.startScanning, systemImage: "play.fill")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
            } else if viewState.canStopScanning {
                Button(action: onStopScanning) {
                    Label(L10n.Action.stopScanning, systemImage: "stop.fill")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .buttonStyle(.bordered)
                .tint(.red)
                .controlSize(.regular)
            }
        }
    }
    
    private var secondaryActions: some View {
        HStack(spacing: 8) {
            Button(action: onSortDevices) {
                Label(L10n.Action.sort, systemImage: "arrow.up.arrow.down")
                    .labelStyle(.iconOnly)
                    .font(.body)
            }
            .buttonStyle(.bordered)
            .controlSize(.regular)
            .disabled(viewState.devices.isEmpty)
            .opacity(viewState.devices.isEmpty ? 0.5 : 1.0)
            
            Button(action: onShowFilter) {
                Label(L10n.Action.filter, systemImage: viewState.isFilterEnabled ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                    .labelStyle(.iconOnly)
                    .font(.body)
            }
            .buttonStyle(.bordered)
            .tint(viewState.isFilterEnabled ? .orange : .blue)
            .controlSize(.regular)
        }
    }
}
