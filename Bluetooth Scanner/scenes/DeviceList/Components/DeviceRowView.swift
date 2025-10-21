//
//  DeviceRowView.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import SwiftUI

struct DeviceRowView: View {
    let device: PeripheralModel
    let onConnect: () -> Void
    let onViewDetails: () -> Void
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            mainRow
            
            if isExpanded {
                expandedDetails
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.95, anchor: .top)),
                        removal: .opacity
                    ))
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .clipped()
    }
    
    // MARK: - Main Row
    private var mainRow: some View {
        Button(action: {
            if !device.isStale {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }
        }) {
            HStack(spacing: 12) {
                deviceInfo
                Spacer(minLength: 8)
                actionButtons
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .opacity(device.isStale ? 0.5 : 1.0)
    }
    
    private var deviceInfo: some View {
        HStack(spacing: 12) {
            SignalStrengthIcon(rssi: device.rssi)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(device.displayName)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(device.isStale ? .secondary : .primary)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Text(device.rssiString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if !device.serviceUUIDs.isEmpty {
                        Circle()
                            .fill(Color.secondary)
                            .frame(width: 3, height: 3)
                        
                        Text(L10n.Device.servicesCount(device.serviceUUIDs.count, device.serviceUUIDs.count == 1 ? "" : "s"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if device.isStale {
                        Circle()
                            .fill(Color.secondary)
                            .frame(width: 3, height: 3)
                        
                        Text(L10n.Device.lost)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
    
    private var actionButtons: some View {
        HStack(spacing: 8) {
            if device.isConnectable && !device.isStale {
                Text(L10n.Device.connectable)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(6)
            }
            
            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 20, height: 20)
        }
    }
    
    // MARK: - Expanded Details
    private var expandedDetails: some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                basicInfoSection
                
                if !device.serviceUUIDs.isEmpty {
                    serviceUUIDsSection
                }
                
                if let manufacturerData = device.manufacturerData {
                    manufacturerDataSection(data: manufacturerData)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
            
            Button(action: {
                onViewDetails()
            }) {
                Text(L10n.Action.viewFullDetails)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.bordered)
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
    }
    
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L10n.Details.advertisementData)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            
            InfoRow(label: L10n.Device.rssi, value: device.rssiString, isSmallFont: true)
            InfoRow(label: L10n.Device.connectable, value: device.isConnectable ? L10n.Device.yes : L10n.Device.no, isSmallFont: true)
            
            if let txPower = device.txPowerLevel {
                InfoRow(label: L10n.Device.txPower, value: "\(txPower) dBm", isSmallFont: true)
            }
            
            InfoRow(label: L10n.Device.lastSeen, value: formatDate(device.lastSeen), isSmallFont: true)
            
            ForEach(Array(device.formattedAdvertisementData.enumerated()), id: \.offset) { _, data in
                if data.label != "Device is Connectable" {
                    InfoRow(label: data.label, value: data.value, isSmallFont: true)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(8)
    }
    
    private var advertisementDataSection: some View {
        EmptyView()
    }
    
    private var serviceUUIDsSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L10n.Details.serviceUuids)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            
            FlowLayout(spacing: 6) {
                ForEach(device.serviceUUIDs, id: \.self) { uuid in
                    Text(uuid)
                        .font(.caption2)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray5))
                        .cornerRadius(6)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(8)
    }
    
    private func manufacturerDataSection(data: Data) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L10n.Device.manufacturerData)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            
            Text(data.map { String(format: "%02X", $0) }.joined(separator: " "))
                .font(.caption2)
                .foregroundColor(.primary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(.systemGray5))
                .cornerRadius(6)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(8)
    }
    
    // MARK: - Helper
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - FlowLayout Helper
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}
