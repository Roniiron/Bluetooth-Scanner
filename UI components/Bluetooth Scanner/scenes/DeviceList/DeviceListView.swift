//
//  ContentView.swift
//  Bluetooth Scanner
//
//  Created by Roni on 13. 10. 2025..
//

import SwiftUI

// MARK: - DeviceListView

struct DeviceListView: View {
    
    @StateObject private var viewModel = DeviceListViewModel()
    @State private var selectedDevice: PeripheralModel?
    @State private var showingDeviceDetail = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HeaderView(
                    bluetoothState: viewModel.bluetoothState,
                    deviceCount: viewModel.devices.count,
                    isScanning: viewModel.isScanning,
                    isFilterEnabled: viewModel.isFilterEnabled,
                    filterText: viewModel.filterStatusText,
                    canStartScanning: viewModel.canStartScanning,
                    canStopScanning: viewModel.canStopScanning,
                    onStartScan: viewModel.startScanning,
                    onStopScan: viewModel.stopScanning,
                    onSort: viewModel.sortDevicesBySignalStrength,
                    onFilter: viewModel.toggleFilterPopup
                )
                
                SearchField(text: $searchText)
                
                if viewModel.devices.isEmpty {
                    EmptyStateView(
                        bluetoothState: viewModel.bluetoothState,
                        isScanning: viewModel.isScanning
                    )
                    .padding(.top, 40)
                } else {
                    DeviceList(
                        devices: filteredDevices,
                        isScanning: viewModel.isScanning,
                        onDeviceSelected: selectDevice,
                        onRefresh: handleRefresh
                    )
                }
            }
            .navigationTitle("Bluetooth Scanner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear") {
                        viewModel.clearDevices()
                    }
                    .disabled(viewModel.devices.isEmpty)
                }
            }
            .onTapGesture {
                dismissKeyboard()
            }
            .alert("Error", isPresented: $viewModel.showingError) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage ?? "Unknown error")
            }
            .sheet(isPresented: $showingDeviceDetail) {
                if let device = selectedDevice {
                    DeviceDetailView(device: device)
                }
            }
            .overlay {
                if viewModel.showingFilterPopup {
                    FilterOverlay(
                        isFilterEnabled: $viewModel.isFilterEnabled,
                        minimumRSSI: $viewModel.minimumRSSI,
                        signalBars: viewModel.signalBars(for: Int(viewModel.minimumRSSI)),
                        onDismiss: viewModel.toggleFilterPopup,
                        onFilterChange: viewModel.updateFilter
                    )
                }
            }
        }
    }
    
    private var filteredDevices: [PeripheralModel] {
        guard !searchText.isEmpty else { return viewModel.devices }
        return viewModel.devices.filter {
            $0.displayName.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private func selectDevice(_ device: PeripheralModel) {
        dismissKeyboard()
        selectedDevice = device
        showingDeviceDetail = true
    }
    
    private func handleRefresh() {
        if viewModel.isScanning {
            viewModel.stopScanning()
        } else {
            viewModel.startScanning()
        }
    }
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

// MARK: - HeaderView

struct HeaderView: View {
    let bluetoothState: CBManagerState
    let deviceCount: Int
    let isScanning: Bool
    let isFilterEnabled: Bool
    let filterText: String
    let canStartScanning: Bool
    let canStopScanning: Bool
    let onStartScan: () -> Void
    let onStopScan: () -> Void
    let onSort: () -> Void
    let onFilter: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            BluetoothStatusRow(state: bluetoothState)
            DeviceCountRow(count: deviceCount, state: bluetoothState)
            
            if isFilterEnabled {
                FilterStatusRow(text: filterText)
            }
            
            ControlsRow(
                canStartScanning: canStartScanning,
                canStopScanning: canStopScanning,
                isScanning: isScanning,
                onStartScan: onStartScan,
                onStopScan: onStopScan,
                onSort: onSort,
                onFilter: onFilter
            )
        }
        .padding()
        .background(Color(.systemGray6))
    }
}

// MARK: - BluetoothStatusRow

struct BluetoothStatusRow: View {
    let state: CBManagerState
    
    var body: some View {
        HStack {
            Image(systemName: "antenna.radiowaves.left.and.right")
                .foregroundColor(state == .poweredOn ? .green : .red)
            
            Text(stateText)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
    
    private var stateText: String {
        switch state {
        case .poweredOn: return "Bluetooth is On"
        case .poweredOff: return "Bluetooth is Off"
        case .resetting: return "Bluetooth is Resetting"
        case .unauthorized: return "Bluetooth Unauthorized"
        case .unsupported: return "Bluetooth Unsupported"
        case .unknown: return "Bluetooth State Unknown"
        @unknown default: return "Unknown State"
        }
    }
}

// MARK: - DeviceCountRow

struct DeviceCountRow: View {
    let count: Int
    let state: CBManagerState
    
    var body: some View {
        HStack {
            Text(countText)
                .font(.headline)
            Spacer()
        }
    }
    
    private var countText: String {
        guard state == .poweredOn else { return "" }
        return count == 1 ? "1 device found" : "\(count) devices found"
    }
}

// MARK: - FilterStatusRow

struct FilterStatusRow: View {
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                .foregroundColor(.blue)
                .font(.caption)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.blue)
            
            Spacer()
        }
    }
}

// MARK: - ControlsRow

struct ControlsRow: View {
    let canStartScanning: Bool
    let canStopScanning: Bool
    let isScanning: Bool
    let onStartScan: () -> Void
    let onStopScan: () -> Void
    let onSort: () -> Void
    let onFilter: () -> Void
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 16) {
            ScanButtons(
                canStart: canStartScanning,
                canStop: canStopScanning,
                onStart: onStartScan,
                onStop: onStopScan
            )
            
            IconButton(
                icon: "arrow.up.and.down.text.horizontal",
                action: onSort
            )
            
            IconButton(
                icon: "line.3.horizontal.decrease.circle",
                action: onFilter
            )
            
            Spacer()
            
            ScanStatusLabel(isScanning: isScanning)
        }
    }
}

// MARK: - ScanButtons

struct ScanButtons: View {
    let canStart: Bool
    let canStop: Bool
    let onStart: () -> Void
    let onStop: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if canStart {
                Button("Start", action: onStart)
                    .buttonStyle(.borderedProminent)
                    .frame(width: 120, alignment: .leading)
            }
            
            if canStop {
                Button("Stop", action: onStop)
                    .buttonStyle(.bordered)
                    .frame(width: 120, alignment: .leading)
            }
        }
    }
}

// MARK: - IconButton

struct IconButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - ScanStatusLabel

struct ScanStatusLabel: View {
    let isScanning: Bool
    
    var body: some View {
        Group {
            if isScanning {
                HStack(spacing: 4) {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Scanning")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("Not Scanning")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(height: 20)
    }
}

// MARK: - SearchField

struct SearchField: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search peripheral by name", text: $text)
                .textFieldStyle(.plain)
            
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

// MARK: - EmptyStateView

struct EmptyStateView: View {
    let bluetoothState: CBManagerState
    let isScanning: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            if isScanning {
                ScanningEmptyState()
            } else if bluetoothState != .poweredOn {
                BluetoothUnavailableState(state: bluetoothState)
            } else {
                IdleEmptyState()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

// MARK: - ScanningEmptyState

struct ScanningEmptyState: View {
    var body: some View {
        ProgressView()
            .scaleEffect(1.2)
            .progressViewStyle(.circular)
        
        Text("Scanning for Devices...")
            .font(.title3)
            .fontWeight(.medium)
        
        Text("Looking for nearby Bluetooth devices...")
            .font(.subheadline)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
    }
}

// MARK: - IdleEmptyState

struct IdleEmptyState: View {
    var body: some View {
        Text("Start scanning to discover nearby Bluetooth devices")
            .font(.subheadline)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
    }
}

// MARK: - BluetoothUnavailableState

struct BluetoothUnavailableState: View {
    let state: CBManagerState
    
    var body: some View {
        Image(systemName: "antenna.radiowaves.left.and.right.slash")
            .font(.system(size: 40))
            .foregroundColor(.red)
        
        Text(title)
            .font(.title3)
            .fontWeight(.medium)
        
        Text(message)
            .font(.subheadline)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
        
        Button(buttonTitle, action: openSettings)
            .buttonStyle(.bordered)
    }
    
    private var title: String {
        switch state {
        case .poweredOff: return "Bluetooth is Off"
        case .unauthorized: return "Bluetooth Access Denied"
        case .unsupported: return "Bluetooth Not Supported"
        case .resetting: return "Bluetooth Resetting"
        default: return "Bluetooth Unavailable"
        }
    }
    
    private var message: String {
        switch state {
        case .poweredOff:
            return "Please turn on Bluetooth in Settings to scan for devices"
        case .unauthorized:
            return "Please allow Bluetooth access in Settings to scan for devices"
        case .unsupported:
            return "This device does not support Bluetooth Low Energy"
        case .resetting:
            return "Bluetooth is resetting. Please wait and try again"
        default:
            return "Bluetooth state is unknown. Please wait and try again"
        }
    }
    
    private var buttonTitle: String {
        state == .unauthorized ? "Open Settings" : "Enable Bluetooth"
    }
    
    private func openSettings() {
        switch state {
        case .unauthorized:
            openAppSettings()
        case .poweredOff:
            showBluetoothAlert()
        default:
            openAppSettings()
        }
    }
    
    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
    
    private func showBluetoothAlert() {
        let alert = UIAlertController(
            title: "Bluetooth is Off",
            message: "To scan for devices, please enable Bluetooth:\n\n• Swipe down from top-right corner\n• Tap the Bluetooth icon\n• Or go to Settings > Bluetooth",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        window.rootViewController?.present(alert, animated: true)
    }
}

// MARK: - DeviceList

struct DeviceList: View {
    let devices: [PeripheralModel]
    let isScanning: Bool
    let onDeviceSelected: (PeripheralModel) -> Void
    let onRefresh: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            if !devices.isEmpty {
                PullToRefreshHint(isScanning: isScanning)
            }
            
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(devices) { device in
                        DeviceRowView(
                            device: device,
                            onTap: { onDeviceSelected(device) }
                        )
                        .padding(.horizontal, 8)
                        .transition(.opacity)
                    }
                }
                .padding(.vertical, 8)
            }
            .refreshable {
                onRefresh()
            }
        }
    }
}

// MARK: - PullToRefreshHint
struct PullToRefreshHint: View {
    let isScanning: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "arrow.down")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(isScanning ? "Pull down to cancel scanning" : "Pull down to rescan")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
        .opacity(0.6)
    }
}

// MARK: - DeviceRowView

struct DeviceRowView: View {
    let device: PeripheralModel
    let onTap: () -> Void
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            DeviceRowMain(
                device: device,
                isExpanded: isExpanded,
                onTap: toggleExpansion,
                onConnect: handleConnect
            )
            
            if isExpanded {
                DeviceRowExpanded(
                    device: device,
                    onViewDetails: onTap
                )
            }
        }
    }
    
    private func toggleExpansion() {
        guard !device.isStale else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            isExpanded.toggle()
        }
    }
    
    private func handleConnect() {
        guard !device.isStale else { return }
        onTap()
    }
}

// MARK: - DeviceRowMain

struct DeviceRowMain: View {
    let device: PeripheralModel
    let isExpanded: Bool
    let onTap: () -> Void
    let onConnect: () -> Void
    
    var body: some View {
        HStack {
            DeviceInfo(device: device)
            Spacer()
            
            if device.isConnectable {
                Button("Connect", action: onConnect)
                    .buttonStyle(.borderedProminent)
                    .font(.caption)
                    .disabled(device.isStale)
                    .frame(minWidth: 80, alignment: .trailing)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .opacity(device.isStale ? 0.5 : 1.0)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        .overlay(alignment: .bottom) {
            if !isExpanded {
                Divider()
            }
        }
    }
}

// MARK: - DeviceInfo

struct DeviceInfo: View {
    let device: PeripheralModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(device.displayName)
                .font(.headline)
                .foregroundColor(device.isStale ? .secondary : .primary)
            
            HStack(spacing: 8) {
                SignalStrengthIcon(rssi: device.rssi)
                
                Text(device.rssiString)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if !device.serviceUUIDs.isEmpty {
                    Text("\(device.serviceUUIDs.count) services")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if device.isStale {
                    Text("(Lost)")
                        .font(.caption2)
                        .foregroundColor(.red)
                }
            }
        }
    }
}

// MARK: - DeviceRowExpanded

struct DeviceRowExpanded: View {
    let device: PeripheralModel
    let onViewDetails: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            DeviceDetails(device: device)
            
            VStack {
                Spacer()
                Button("View Details", action: onViewDetails)
                    .buttonStyle(.borderedProminent)
                    .font(.caption)
                Spacer()
            }
            .frame(minWidth: 80, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .background(Color(.systemGray6).opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .overlay(alignment: .bottom) {
            Divider()
        }
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }
}

// MARK: - DeviceDetails

struct DeviceDetails: View {
    let device: PeripheralModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            DeviceBasicInfo(device: device)
            
            if !device.formattedAdvertisementData.isEmpty {
                DeviceAdvertisementData(data: device.formattedAdvertisementData)
            }
            
            if !device.serviceUUIDs.isEmpty {
                DeviceServiceUUIDs(uuids: device.serviceUUIDs)
            }
            
            if let manufacturerData = device.manufacturerData {
                DeviceManufacturerData(data: manufacturerData)
            }
        }
    }
}

// MARK: - DeviceBasicInfo

struct DeviceBasicInfo: View {
    let device: PeripheralModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Device Information")
                .font(.caption)
                .fontWeight(.semibold)
            
            InfoRow(label: "RSSI", value: device.rssiString, isSmallFont: true)
            InfoRow(label: "Connectable", value: device.isConnectable ? "Yes" : "No", isSmallFont: true)
            InfoRow(label: "Last Seen", value: device.lastSeen.formatted(date: .omitted, time: .standard), isSmallFont: true)
            
            if let txPower = device.txPowerLevel {
                InfoRow(label: "TX Power", value: "\(txPower) dBm", isSmallFont: true)
            }
        }
    }
}

// MARK: - DeviceAdvertisementData

struct DeviceAdvertisementData: View {
    let data: [(label: String, value: String)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Advertisement Data")
                .font(.caption)
                .fontWeight(.semibold)
            
            ForEach(data.indices, id: \.self) { index in
                InfoRow(label: data[index].label, value: data[index].value, isSmallFont: true)
            }
        }
    }
}

// MARK: - DeviceServiceUUIDs

struct DeviceServiceUUIDs: View {
    let uuids: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Service UUIDs")
                .font(.caption)
                .fontWeight(.semibold)
            
            ForEach(uuids, id: \.self) { uuid in
                Text(uuid)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(.systemGray6))
                    .cornerRadius(3)
            }
        }
    }
}

// MARK: - DeviceManufacturerData

struct DeviceManufacturerData: View {
    let data: Data
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Manufacturer Data")
                .font(.caption)
                .fontWeight(.semibold)
            
            Text(data.map { String(format: "%02X", $0) }.joined(separator: " "))
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color(.systemGray6))
                .cornerRadius(3)
        }
    }
}

// MARK: - FilterOverlay

struct FilterOverlay: View {
    @Binding var isFilterEnabled: Bool
    @Binding var minimumRSSI: Double
    let signalBars: Int
    let onDismiss: () -> Void
    let onFilterChange: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture(perform: onDismiss)
            
            FilterPopup(
                isFilterEnabled: $isFilterEnabled,
                minimumRSSI: $minimumRSSI,
                signalBars: signalBars,
                onFilterChange: onFilterChange
            )
        }
    }
}

// MARK: - FilterPopup

struct FilterPopup: View {
    @Binding var isFilterEnabled: Bool
    @Binding var minimumRSSI: Double
    let signalBars: Int
    let onFilterChange: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Toggle("Filter by Signal", isOn: $isFilterEnabled)
                .onChange(of: isFilterEnabled) { _ in
                    onFilterChange()
                }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Minimum RSSI: \(Int(minimumRSSI)) dB")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("(\(signalBars) bars)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                
                Slider(value: $minimumRSSI, in: -100...(-30), step: 1)
                    .onChange(of: minimumRSSI) { _ in
                        if isFilterEnabled {
                            onFilterChange()
                        }
                    }
                    .disabled(!isFilterEnabled)
                
                HStack {
                    Text("-100 dB")
                        .font(.caption2)
                        .foregroundColor(.white)
                    Spacer()
                    Text("-30 dB")
                        .font(.caption2)
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .frame(width: 400, height: 300)
        .background(Color(.systemBlue))
        .cornerRadius(12)
        .shadow(radius: 10)
    }
}

// MARK: - Preview

struct DeviceListView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceListView()
    }
}
