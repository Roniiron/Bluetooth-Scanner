//
//  FilterPopupView.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import SwiftUI

struct FilterPopupView: View {
    @Binding var isFilterEnabled: Bool
    @Binding var minimumRSSI: Double
    let onFilterChange: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "line.3.horizontal.decrease.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.blue)
                
                Text(L10n.Filter.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            Divider()
            
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(L10n.Filter.bySignalStrength)
                                .font(.body)
                                .fontWeight(.medium)
                            
                            Text(L10n.Filter.showStrongSignals)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $isFilterEnabled)
                            .labelsHidden()
                            .onChange(of: isFilterEnabled) {
                                onFilterChange()
                            }
                    }
                }
                .padding(16)
                .background(Color(.systemGray6).opacity(0.5))
                .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 8) {
                        SignalStrengthIcon(rssi: Int(minimumRSSI))
                            .frame(width: 24, height: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(L10n.Filter.minimumSignalStrength)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            HStack(spacing: 4) {
                                Text("\(Int(minimumRSSI)) dB")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("•")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("\(SignalStrengthCalculator.getSignalBars(for: Int(minimumRSSI))) bars")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                    }
                    
                    VStack(spacing: 8) {
                        Slider(value: $minimumRSSI, in: -100...(-30), step: 1)
                            .onChange(of: minimumRSSI) {
                                if isFilterEnabled {
                                    onFilterChange()
                                }
                            }
                            .disabled(!isFilterEnabled)
                            .tint(.blue)
                        
                        HStack {
                            Text(L10n.Filter.weak)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(L10n.Filter.strong)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(16)
                .background(Color(.systemGray6).opacity(0.5))
                .cornerRadius(12)
                .opacity(isFilterEnabled ? 1.0 : 0.6)
                
                HStack(spacing: 12) {
                    Image(systemName: "info.circle.fill")
                        .font(.body)
                        .foregroundStyle(.blue)
                    
                    Text(L10n.Filter.infoMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer(minLength: 0)
                }
                .padding(12)
                .background(Color(.systemBlue).opacity(0.08))
                .cornerRadius(10)
            }
            .padding(20)
        }
        .frame(width: 380)
        .background(
            Color(.systemBackground)
                .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
        )
        .cornerRadius(16)
    }
}

