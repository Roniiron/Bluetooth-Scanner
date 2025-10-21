//
//  CharacteristicsSectionView.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import SwiftUI
import CoreBluetooth

struct CharacteristicsSectionView: View {
    let viewState: DeviceDetailViewState
    let onReadValue: (CBCharacteristic) -> Void
    let onSetNotification: (Bool, CBCharacteristic) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader
            
            LazyVStack(spacing: 12) {
                ForEach(viewState.characteristics, id: \.uuid) { characteristic in
                    CharacteristicRowView(
                        characteristic: characteristic,
                        onReadValue: {
                            onReadValue(characteristic)
                        },
                        onSetNotification: { enabled in
                            onSetNotification(enabled, characteristic)
                        },
                        value: viewState.characteristicValue,
                        isReading: viewState.isCharacteristicReading(characteristic)
                    )
                }
            }
        }
    }
    
    private var sectionHeader: some View {
        HStack {
            Text(L10n.Details.characteristics)
                .font(.title3)
                .fontWeight(.semibold)
            
            Spacer()
            
            Image(systemName: "tray.2.fill")
                .font(.title3)
                .foregroundStyle(.blue)
        }
    }
}

