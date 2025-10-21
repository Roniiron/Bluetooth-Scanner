//
//  DeviceInfoSectionView.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import SwiftUI

struct DeviceInfoSectionView: View {
    let viewState: DeviceDetailViewState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader
            
            VStack(spacing: 0) {
                InfoRowWithIcon(
                    icon: "personalhotspot",
                    label: L10n.Device.name,
                    value: viewState.deviceName
                )
                
                Divider().padding(.leading, 44)
                
                InfoRowWithIcon(
                    icon: "antenna.radiowaves.left.and.right",
                    label: L10n.Device.signalStrength,
                    value: viewState.deviceRSSI
                )
                
                Divider().padding(.leading, 44)
                
                InfoRowWithIcon(
                    icon: viewState.isConnectableString == "Yes" ? "checkmark.circle.fill" : "xmark.circle.fill",
                    label: L10n.Device.connectable,
                    value: viewState.isConnectableString,
                    valueColor: viewState.isConnectableString == "Yes" ? .green : .secondary
                )
                
                if viewState.txPowerLevel != "N/A" {
                    Divider().padding(.leading, 44)
                    
                    InfoRowWithIcon(
                        icon: "bolt.fill",
                        label: L10n.Device.txPower,
                        value: viewState.txPowerLevel
                    )
                }
                
                if viewState.manufacturerData != "N/A" {
                    Divider().padding(.leading, 44)
                    
                    InfoRowWithIcon(
                        icon: "building.2.fill",
                        label: L10n.Device.manufacturerData,
                        value: viewState.manufacturerData
                    )
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }
    
    private var sectionHeader: some View {
        HStack {
            Text(L10n.Details.deviceInfo)
                .font(.title3)
                .fontWeight(.semibold)
            
            Spacer()
            
            Image(systemName: "info.circle.fill")
                .font(.title3)
                .foregroundStyle(.blue)
        }
    }
}

// MARK: - Info Row with Icon
struct InfoRowWithIcon: View {
    let icon: String
    let label: String
    let value: String
    var valueColor: Color = .primary
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.blue)
                .frame(width: 20, height: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.body)
                    .foregroundColor(valueColor)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

