//
//  DeviceListView.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import Foundation
import SwiftUI

struct DeviceListView: View {
    @StateObject private var viewModel: DeviceListViewModel
    @State private var navigationPath = NavigationPath()
    @State private var searchText = ""
    
    private let bleManager: BLEManager
    private let settingsNavigator = SettingsNavigator()
    private let filterService = DeviceFilterService()
    
    init(bleManager: BLEManager) {
        self.bleManager = bleManager
        _viewModel = StateObject(wrappedValue: DeviceListViewModel(bluetoothService: bleManager))
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                DeviceListHeaderView(
                    viewState: viewModel.viewState,
                    onStartScanning: { viewModel.startScanning() },
                    onStopScanning: { viewModel.stopScanning() },
                    onSortDevices: { viewModel.sortDevicesBySignalStrength() },
                    onShowFilter: { viewModel.showFilterPopup() }
                )
                
                SearchBarView(searchText: $searchText)
                
                if viewModel.viewState.shouldShowEmptyState {
                    VStack {
                        EmptyStateView(
                            configuration: viewModel.viewState.emptyState,
                            onSettingsAction: {
                                settingsNavigator.openSettings(for: viewModel.viewState.bluetoothState)
                            }
                        )
                        Spacer()
                    }
                } else {
                    deviceListContent
                }
            }
            .navigationTitle(L10n.App.readyToScan)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    clearButton
                }
            }
            .dismissKeyboardOnTap()
            .alert(L10n.Error.unknown, isPresented: $viewModel.showingError) {
                Button(L10n.Action.done) { }
            } message: {
                Text(viewModel.errorMessage ?? L10n.Error.unknown)
            }
            .navigationDestination(for: PeripheralModel.self) { device in
                DeviceDetailView(device: device, bleManager: bleManager)
                    .toolbarRole(.editor)
            }
            .overlay(filterPopupOverlay)
        }
    }
    
    // MARK: - Subviews
    private var deviceListContent: some View {
        VStack(spacing: 0) {
            pullToRefreshHint
            
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(filteredDevices) { device in
                        DeviceRowView(
                            device: device,
                            onConnect: { handleDeviceSelection(device) },
                            onViewDetails: { handleDeviceSelection(device) }
                        )
                        .padding(.horizontal, 8)
                        .transition(.opacity)
                    }
                }
                .padding(.vertical, 8)
            }
            .refreshable {
                handlePullToRefresh()
            }
        }
    }
    
    private var pullToRefreshHint: some View {
        Group {
            if !filteredDevices.isEmpty {
                HStack {
                    Image(systemName: "arrow.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(viewModel.viewState.pullToRefreshHint)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)
                .padding(.bottom, 4)
                .opacity(0.6)
                .padding(.horizontal, 16)
                .background(Color(.systemBackground))
            }
        }
    }
    
    private var clearButton: some View {
        Button("Clear") {
            viewModel.clearDevices()
        }
        .disabled(!viewModel.viewState.shouldShowClearButton)
    }
    
    @ViewBuilder
    private var filterPopupOverlay: some View {
        if viewModel.showingFilterPopup {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeOut(duration: 0.2)) {
                        viewModel.showingFilterPopup = false
                    }
                }
                .transition(.opacity)
            
            FilterPopupView(
                isFilterEnabled: $viewModel.isFilterEnabled,
                minimumRSSI: $viewModel.minimumRSSI,
                onFilterChange: { viewModel.updateFilter() }
            )
            .transition(.asymmetric(
                insertion: .scale(scale: 0.9).combined(with: .opacity),
                removal: .scale(scale: 0.95).combined(with: .opacity)
            ))
        }
    }
    
    private var filteredDevices: [PeripheralModel] {
        filterService.filterBySearchText(
            devices: viewModel.viewState.devices,
            searchText: searchText
        )
    }
    
    // MARK: - Actions
    private func handleDeviceSelection(_ device: PeripheralModel) {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
        navigationPath.append(device)
    }
    
    private func handlePullToRefresh() {
        if viewModel.viewState.isScanning {
            viewModel.stopScanning()
        } else {
            viewModel.startScanning()
        }
    }
}

// MARK: - Preview
struct DeviceListView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceListView(bleManager: BLEManager())
    }
}
