//
//  ExpandableInfoCell.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import SwiftUI

struct ExpandableInfoCell: View {
    let icon: String
    let label: String
    let value: String
    let expandedContent: String?
    var valueColor: Color = .primary
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                    isExpanded.toggle()
                }
            } label: {
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
                            .lineLimit(isExpanded ? nil : 1)
                    }
                    
                    Spacer()
                    
                    if expandedContent != nil {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            if isExpanded, let content = expandedContent {
                expandedSection(content: content)
                    .transition(.asymmetric(
                        insertion: .push(from: .top).combined(with: .opacity),
                        removal: .push(from: .bottom).combined(with: .opacity)
                    ))
            }
        }
    }
    
    @ViewBuilder
    private func expandedSection(content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()
                .padding(.leading, 44)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Details")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                
                Text(content)
                    .font(.callout)
                    .foregroundColor(.primary)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 0) {
        ExpandableInfoCell(
            icon: "antenna.radiowaves.left.and.right",
            label: "Identifier",
            value: "E112-8559-435F-5176",
            expandedContent: "E1128559-435F-5176-8E5C-8B1F8B6F8C8A\n\nThis is the unique identifier assigned to this Bluetooth peripheral device."
        )
        
        Divider().padding(.leading, 44)
        
        ExpandableInfoCell(
            icon: "personalhotspot",
            label: "Device Name",
            value: "Roni's iPhone",
            expandedContent: nil
        )
        
        Divider().padding(.leading, 44)
        
        ExpandableInfoCell(
            icon: "checkmark.circle.fill",
            label: "Connectable",
            value: "Yes",
            expandedContent: "This device can accept incoming connections from other Bluetooth devices.",
            valueColor: .green
        )
    }
    .background(Color(.systemBackground))
    .cornerRadius(12)
    .padding()
    .background(Color(.systemGroupedBackground))
}

