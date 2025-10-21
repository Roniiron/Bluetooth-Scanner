// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum L10n {
  public enum Action {
    /// Connect
    public static let connect = L10n.tr("Localizable", "action.connect", fallback: "Connect")
    /// Disconnect
    public static let disconnect = L10n.tr("Localizable", "action.disconnect", fallback: "Disconnect")
    /// Done
    public static let done = L10n.tr("Localizable", "action.done", fallback: "Done")
    /// Enable Bluetooth
    public static let enableBluetooth = L10n.tr("Localizable", "action.enableBluetooth", fallback: "Enable Bluetooth")
    /// Filter
    public static let filter = L10n.tr("Localizable", "action.filter", fallback: "Filter")
    /// Notify
    public static let notify = L10n.tr("Localizable", "action.notify", fallback: "Notify")
    /// Open Settings
    public static let openSettings = L10n.tr("Localizable", "action.openSettings", fallback: "Open Settings")
    /// Read
    public static let read = L10n.tr("Localizable", "action.read", fallback: "Read")
    /// Refresh
    public static let refresh = L10n.tr("Localizable", "action.refresh", fallback: "Refresh")
    /// Sort
    public static let sort = L10n.tr("Localizable", "action.sort", fallback: "Sort")
    /// Start Scanning
    public static let startScanning = L10n.tr("Localizable", "action.startScanning", fallback: "Start Scanning")
    /// Stop Scanning
    public static let stopScanning = L10n.tr("Localizable", "action.stopScanning", fallback: "Stop Scanning")
    /// View Full Details
    public static let viewFullDetails = L10n.tr("Localizable", "action.viewFullDetails", fallback: "View Full Details")
  }
  public enum App {
    /// No Devices Found
    public static let noDevicesFound = L10n.tr("Localizable", "app.noDevicesFound", fallback: "No Devices Found")
    /// Not Scanning
    public static let notScanning = L10n.tr("Localizable", "app.notScanning", fallback: "Not Scanning")
    /// Localizable.strings
    ///   Bluetooth Scanner
    ///   
    ///   English localization strings
    public static let readyToScan = L10n.tr("Localizable", "app.readyToScan", fallback: "Ready to Scan")
    /// Scanning for Devices...
    public static let scanning = L10n.tr("Localizable", "app.scanning", fallback: "Scanning for Devices...")
    /// Scanning
    public static let scanningStatus = L10n.tr("Localizable", "app.scanningStatus", fallback: "Scanning")
  }
  public enum Bluetooth {
    /// Bluetooth is Off
    public static let poweredOff = L10n.tr("Localizable", "bluetooth.poweredOff", fallback: "Bluetooth is Off")
    /// Bluetooth Resetting
    public static let resetting = L10n.tr("Localizable", "bluetooth.resetting", fallback: "Bluetooth Resetting")
    /// Bluetooth Access Denied
    public static let unauthorized = L10n.tr("Localizable", "bluetooth.unauthorized", fallback: "Bluetooth Access Denied")
    /// Bluetooth Unknown
    public static let unknown = L10n.tr("Localizable", "bluetooth.unknown", fallback: "Bluetooth Unknown")
    /// Bluetooth Not Supported
    public static let unsupported = L10n.tr("Localizable", "bluetooth.unsupported", fallback: "Bluetooth Not Supported")
  }
  public enum Characteristic {
    /// Subscribe
    public static let notify = L10n.tr("Localizable", "characteristic.notify", fallback: "Subscribe")
    /// Notifications enabled
    public static let notifySuccess = L10n.tr("Localizable", "characteristic.notifySuccess", fallback: "Notifications enabled")
    /// Operation failed
    public static let operationFailed = L10n.tr("Localizable", "characteristic.operationFailed", fallback: "Operation failed")
    /// Read Value
    public static let read = L10n.tr("Localizable", "characteristic.read", fallback: "Read Value")
    /// Value read successfully
    public static let readSuccess = L10n.tr("Localizable", "characteristic.readSuccess", fallback: "Value read successfully")
    /// Write Value
    public static let write = L10n.tr("Localizable", "characteristic.write", fallback: "Write Value")
    /// Value written successfully
    public static let writeSuccess = L10n.tr("Localizable", "characteristic.writeSuccess", fallback: "Value written successfully")
  }
  public enum Details {
    /// Advertisement Data
    public static let advertisementData = L10n.tr("Localizable", "details.advertisementData", fallback: "Advertisement Data")
    /// Cancel
    public static let cancel = L10n.tr("Localizable", "details.cancel", fallback: "Cancel")
    /// Characteristics
    public static let characteristics = L10n.tr("Localizable", "details.characteristics", fallback: "Characteristics")
    /// %d characteristic%@ discovered
    public static func characteristicsDiscovered(_ p1: Int, _ p2: Any) -> String {
      return L10n.tr("Localizable", "details.characteristicsDiscovered", p1, String(describing: p2), fallback: "%d characteristic%@ discovered")
    }
    /// UUID
    public static let characteristicUuid = L10n.tr("Localizable", "details.characteristicUuid", fallback: "UUID")
    /// Current Value
    public static let currentValue = L10n.tr("Localizable", "details.currentValue", fallback: "Current Value")
    /// Device Details
    public static let deviceDetails = L10n.tr("Localizable", "details.deviceDetails", fallback: "Device Details")
    /// Device Disconnected
    public static let deviceDisconnected = L10n.tr("Localizable", "details.deviceDisconnected", fallback: "Device Disconnected")
    /// Device Information
    public static let deviceInfo = L10n.tr("Localizable", "details.deviceInfo", fallback: "Device Information")
    /// Device List
    public static let deviceList = L10n.tr("Localizable", "details.deviceList", fallback: "Device List")
    /// Discover Characteristics
    public static let discoverCharacteristics = L10n.tr("Localizable", "details.discoverCharacteristics", fallback: "Discover Characteristics")
    /// Discovering...
    public static let discovering = L10n.tr("Localizable", "details.discovering", fallback: "Discovering...")
    /// %d characteristics
    public static func multipleCharacteristics(_ p1: Int) -> String {
      return L10n.tr("Localizable", "details.multipleCharacteristics", p1, fallback: "%d characteristics")
    }
    /// %d services
    public static func multipleServices(_ p1: Int) -> String {
      return L10n.tr("Localizable", "details.multipleServices", p1, fallback: "%d services")
    }
    /// No characteristics
    public static let noCharacteristics = L10n.tr("Localizable", "details.noCharacteristics", fallback: "No characteristics")
    /// No characteristics discovered
    public static let noCharacteristicsDiscovered = L10n.tr("Localizable", "details.noCharacteristicsDiscovered", fallback: "No characteristics discovered")
    /// This service doesn't have any discoverable characteristics.
    public static let noCharacteristicsDiscoveredDescription = L10n.tr("Localizable", "details.noCharacteristicsDiscoveredDescription", fallback: "This service doesn't have any discoverable characteristics.")
    /// No manufacturer data
    public static let noManufacturerData = L10n.tr("Localizable", "details.noManufacturerData", fallback: "No manufacturer data")
    /// No services
    public static let noServices = L10n.tr("Localizable", "details.noServices", fallback: "No services")
    /// No services discovered
    public static let noServicesDiscovered = L10n.tr("Localizable", "details.noServicesDiscovered", fallback: "No services discovered")
    /// This device doesn't have any discoverable services or the connection was lost.
    public static let noServicesDiscoveredDescription = L10n.tr("Localizable", "details.noServicesDiscoveredDescription", fallback: "This device doesn't have any discoverable services or the connection was lost.")
    /// 1 characteristic
    public static let oneCharacteristic = L10n.tr("Localizable", "details.oneCharacteristic", fallback: "1 characteristic")
    /// 1 service
    public static let oneService = L10n.tr("Localizable", "details.oneService", fallback: "1 service")
    /// Raw Data
    public static let rawData = L10n.tr("Localizable", "details.rawData", fallback: "Raw Data")
    /// Reconnect
    public static let reconnect = L10n.tr("Localizable", "details.reconnect", fallback: "Reconnect")
    /// Failed to reconnect to device. Please return to device list and try again.
    public static let reconnectFailed = L10n.tr("Localizable", "details.reconnectFailed", fallback: "Failed to reconnect to device. Please return to device list and try again.")
    /// Reconnecting to device...
    public static let reconnecting = L10n.tr("Localizable", "details.reconnecting", fallback: "Reconnecting to device...")
    /// Device has been disconnected. Would you like to reconnect?
    public static let reconnectMessage = L10n.tr("Localizable", "details.reconnectMessage", fallback: "Device has been disconnected. Would you like to reconnect?")
    /// Services
    public static let services = L10n.tr("Localizable", "details.services", fallback: "Services")
    /// Service UUID
    public static let serviceUuid = L10n.tr("Localizable", "details.serviceUuid", fallback: "Service UUID")
    /// Service UUIDs
    public static let serviceUuids = L10n.tr("Localizable", "details.serviceUuids", fallback: "Service UUIDs")
    /// View Services
    public static let viewServices = L10n.tr("Localizable", "details.viewServices", fallback: "View Services")
  }
  public enum Device {
    /// Connectable
    public static let connectable = L10n.tr("Localizable", "device.connectable", fallback: "Connectable")
    /// Connected
    public static let connected = L10n.tr("Localizable", "device.connected", fallback: "Connected")
    /// Connecting
    public static let connecting = L10n.tr("Localizable", "device.connecting", fallback: "Connecting")
    /// Disconnected
    public static let disconnected = L10n.tr("Localizable", "device.disconnected", fallback: "Disconnected")
    /// Discovering Services
    public static let discoveringServices = L10n.tr("Localizable", "device.discoveringServices", fallback: "Discovering Services")
    /// Identifier
    public static let identifier = L10n.tr("Localizable", "device.identifier", fallback: "Identifier")
    /// Interrogating Device
    public static let interrogating = L10n.tr("Localizable", "device.interrogating", fallback: "Interrogating Device")
    /// Last Seen
    public static let lastSeen = L10n.tr("Localizable", "device.lastSeen", fallback: "Last Seen")
    /// Lost
    public static let lost = L10n.tr("Localizable", "device.lost", fallback: "Lost")
    /// Manufacturer Data
    public static let manufacturerData = L10n.tr("Localizable", "device.manufacturerData", fallback: "Manufacturer Data")
    /// Name
    public static let name = L10n.tr("Localizable", "device.name", fallback: "Name")
    /// No
    public static let no = L10n.tr("Localizable", "device.no", fallback: "No")
    /// Not Connectable
    public static let notConnectable = L10n.tr("Localizable", "device.notConnectable", fallback: "Not Connectable")
    /// RSSI
    public static let rssi = L10n.tr("Localizable", "device.rssi", fallback: "RSSI")
    /// %d service%@
    public static func servicesCount(_ p1: Int, _ p2: Any) -> String {
      return L10n.tr("Localizable", "device.servicesCount", p1, String(describing: p2), fallback: "%d service%@")
    }
    /// Signal Strength
    public static let signalStrength = L10n.tr("Localizable", "device.signalStrength", fallback: "Signal Strength")
    /// TX Power
    public static let txPower = L10n.tr("Localizable", "device.txPower", fallback: "TX Power")
    /// Unknown
    public static let unknown = L10n.tr("Localizable", "device.unknown", fallback: "Unknown")
    /// UUID
    public static let uuid = L10n.tr("Localizable", "device.uuid", fallback: "UUID")
    /// Yes
    public static let yes = L10n.tr("Localizable", "device.yes", fallback: "Yes")
  }
  public enum Error {
    /// Unknown error
    public static let unknown = L10n.tr("Localizable", "error.unknown", fallback: "Unknown error")
  }
  public enum Filter {
    /// Filter by Signal Strength
    public static let bySignalStrength = L10n.tr("Localizable", "filter.bySignalStrength", fallback: "Filter by Signal Strength")
    /// Filtering helps you focus on nearby devices with stronger connections
    public static let infoMessage = L10n.tr("Localizable", "filter.infoMessage", fallback: "Filtering helps you focus on nearby devices with stronger connections")
    /// Minimum Signal Strength
    public static let minimumSignalStrength = L10n.tr("Localizable", "filter.minimumSignalStrength", fallback: "Minimum Signal Strength")
    /// Show only devices with strong signals
    public static let showStrongSignals = L10n.tr("Localizable", "filter.showStrongSignals", fallback: "Show only devices with strong signals")
    /// Filtered: ≥%d dB (%d bars)
    public static func statusFormat(_ p1: Int, _ p2: Int) -> String {
      return L10n.tr("Localizable", "filter.statusFormat", p1, p2, fallback: "Filtered: ≥%d dB (%d bars)")
    }
    /// Strong
    public static let strong = L10n.tr("Localizable", "filter.strong", fallback: "Strong")
    /// Filter Devices
    public static let title = L10n.tr("Localizable", "filter.title", fallback: "Filter Devices")
    /// Weak
    public static let `weak` = L10n.tr("Localizable", "filter.weak", fallback: "Weak")
  }
  public enum Message {
    /// Please turn on Bluetooth in Settings to scan for devices
    public static let bluetoothOff = L10n.tr("Localizable", "message.bluetoothOff", fallback: "Please turn on Bluetooth in Settings to scan for devices")
    /// Bluetooth is resetting. Please wait and try again
    public static let bluetoothResetting = L10n.tr("Localizable", "message.bluetoothResetting", fallback: "Bluetooth is resetting. Please wait and try again")
    /// Please allow Bluetooth access in Settings to scan for devices
    public static let bluetoothUnauthorized = L10n.tr("Localizable", "message.bluetoothUnauthorized", fallback: "Please allow Bluetooth access in Settings to scan for devices")
    /// Bluetooth state is unknown. Please wait and try again
    public static let bluetoothUnknown = L10n.tr("Localizable", "message.bluetoothUnknown", fallback: "Bluetooth state is unknown. Please wait and try again")
    /// This device does not support Bluetooth Low Energy
    public static let bluetoothUnsupported = L10n.tr("Localizable", "message.bluetoothUnsupported", fallback: "This device does not support Bluetooth Low Energy")
    /// No nearby devices were found during the last scan
    public static let noDevicesScan = L10n.tr("Localizable", "message.noDevicesScan", fallback: "No nearby devices were found during the last scan")
    /// Pull down to cancel scanning
    public static let pullToRefreshCancel = L10n.tr("Localizable", "message.pullToRefreshCancel", fallback: "Pull down to cancel scanning")
    /// Pull down to rescan
    public static let pullToRefreshScan = L10n.tr("Localizable", "message.pullToRefreshScan", fallback: "Pull down to rescan")
    /// Tap 'Start Scanning' to discover nearby Bluetooth devices
    public static let readyToScan = L10n.tr("Localizable", "message.readyToScan", fallback: "Tap 'Start Scanning' to discover nearby Bluetooth devices")
    /// Looking for nearby Bluetooth devices...
    public static let scanning = L10n.tr("Localizable", "message.scanning", fallback: "Looking for nearby Bluetooth devices...")
  }
  public enum Search {
    /// Search peripheral by name
    public static let placeholder = L10n.tr("Localizable", "search.placeholder", fallback: "Search peripheral by name")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
