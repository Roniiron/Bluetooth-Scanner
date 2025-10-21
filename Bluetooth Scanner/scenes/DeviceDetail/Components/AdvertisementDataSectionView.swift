//
//  AdvertisementDataSectionView.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import SwiftUI

struct AdvertisementDataSectionView: View {
    let viewState: DeviceDetailViewState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader
            
            VStack(alignment: .leading, spacing: 12) {
                // Service UUIDs
                if !viewState.serviceUUIDs.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "list.bullet.circle.fill")
                                .font(.body)
                                .foregroundStyle(.blue)
                            
                            Text(L10n.Details.serviceUuids)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        ForEach(viewState.serviceUUIDs, id: \.self) { uuid in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 6, height: 6)
                                
                                Text(uuid)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .textSelection(.enabled)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6).opacity(0.5))
                            .cornerRadius(8)
                        }
                    }
                }
                
                // Raw Advertisement Data
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.text.fill")
                            .font(.body)
                            .foregroundStyle(.blue)
                        
                        Text(L10n.Details.rawData)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        Text(viewState.advertisementData)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.secondary)
                            .padding(12)
                            .textSelection(.enabled)
                    }
                    .background(Color(.systemGray6).opacity(0.5))
                    .cornerRadius(8)
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }
    
    private var sectionHeader: some View {
        HStack {
            Text(L10n.Details.advertisementData)
                .font(.title3)
                .fontWeight(.semibold)
            
            Spacer()
            
            Image(systemName: "doc.badge.gearshape.fill")
                .font(.title3)
                .foregroundStyle(.blue)
        }
    }
}

