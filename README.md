## Bluetooth Scanner

An iOS app for discovering, filtering, and inspecting Bluetooth Low Energy (BLE) devices.

### Features
- **Live scanning**: Discover nearby BLE peripherals with signal strength (RSSI)
- **Filtering & search**: Quickly narrow devices by name or RSSI
- **Detail inspection**: View advertisement data, services, characteristics, and properties
- **Characteristic I/O**: Read and write characteristic values
- **Notifications**: Subscribe or unsubscribe to characteristic updates
- **Connection management**: Connect or disconnect and observe connection state

### Tech Stack
- SwiftUI
- CoreBluetooth
- Swift Concurrency (async/await)
- MVVM architecture
- SwiftGen for localization

### Architecture
- **Pattern**: MVVM (Views in `scenes/…/Views`, logic in `…ViewModel`)
- **BLE layer**: `BLE/` encapsulates scanning, connection, and service exploration via protocols
- **Notifications**: `BLENotificationService` owns notification subscriptions; `BLEManager` forwards delegate updates
- **Async/await**: All asynchronous BLE operations use Swift concurrency
- **Principles**: SOLID, small focused types, protocol-oriented design

### Requirements
- Xcode 15+
- iOS 16+
- Swift 5.9+

### Getting Started
1. Open `Bluetooth Scanner.xcodeproj` in Xcode.
2. Select a physical iOS device and build/run (BLE requires real hardware; the simulator does not support BLE).
3. On first launch, grant Bluetooth permissions when prompted.

### Usage
- From the Device List, tap the search icon to start scanning.
- Use the filter to refine results by name or signal strength.
- Tap a device to view details (services, characteristics, advertisement data).
- Connect to a device from the detail screen to explore live characteristics.
- Select a characteristic to **read** its value.
- Use supported write types to **write** values to a characteristic.
- Toggle **notifications** for characteristics that support notify or indicate.

### Permissions
Ensure your app target includes the following key in `Info.plist`:
- `NSBluetoothAlwaysUsageDescription`: Reason for accessing Bluetooth to scan and connect to nearby devices

### Troubleshooting
- **No devices found**: Verify Bluetooth is enabled and using a physical device (simulator does not support BLE).
- **Permissions denied**: Re-enable Bluetooth permissions in iOS Settings.
- **Build errors for generated files**: Re-run SwiftGen and clean build folder.


### SwiftGen
This project includes SwiftGen configuration (`swiftgen.yml`).  
If you add or change strings or assets, regenerate them with:

```bash
swiftgen config run --config swiftgen.yml
