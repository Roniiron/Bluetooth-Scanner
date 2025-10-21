//
//  EmptyStateView.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import SwiftUI
import CoreBluetooth

struct EmptyStateView: View {
    let configuration: EmptyStateConfiguration
    let onSettingsAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            if configuration.showProgressIndicator {
                ProgressView()
                    .scaleEffect(1.2)
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
            }
            
            if configuration.showBluetoothIcon {
                Image(systemName: "antenna.radiowaves.left.and.right.slash")
                    .font(.system(size: 40))
                    .foregroundColor(.red)
            }
            
            if configuration.showContent {
                Text(configuration.title)
                    .font(.title3)
                    .fontWeight(.medium)
                
                Text(configuration.message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            if let buttonTitle = configuration.actionButtonTitle {
                Button(buttonTitle) {
                    onSettingsAction()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .padding(.top, 40)
        .opacity(configuration.showContent ? 1.0 : 0.8)
        .animation(.easeInOut(duration: 0.3), value: configuration.showContent)
    }
}

