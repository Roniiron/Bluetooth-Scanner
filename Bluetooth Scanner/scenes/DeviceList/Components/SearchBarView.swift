//
//  SearchBarView.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField(L10n.Search.placeholder, text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

