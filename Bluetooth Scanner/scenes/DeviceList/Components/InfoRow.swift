//
//  InfoRow.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025..
//

import SwiftUI

struct InfoRow: View {
    let label: String
    let value: String
    let isSmallFont: Bool
    
    init(label: String, value: String, isSmallFont: Bool = false) {
        self.label = label
        self.value = value
        self.isSmallFont = isSmallFont
    }
    
    var body: some View {
        HStack {
            Text(label)
                .font(isSmallFont ? .caption2 : .caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(isSmallFont ? .caption2 : .caption)
                .foregroundColor(.primary)
                .lineLimit(nil)
            
            Spacer()
        }
    }
}
