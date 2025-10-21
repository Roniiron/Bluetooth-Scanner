//
//  ConnectionState.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import Foundation

enum ConnectionState: Equatable {
    case disconnected
    case connecting
    case connected
    case discoveringServices
    case interrogating
    case disconnecting
    case notConnectable
    
    var displayText: String {
        switch self {
        case .disconnected:
            return L10n.Device.disconnected
        case .connecting:
            return L10n.Device.connecting
        case .connected:
            return L10n.Device.connected
        case .discoveringServices:
            return L10n.Device.discoveringServices
        case .interrogating:
            return L10n.Device.interrogating
        case .disconnecting:
            return L10n.Device.disconnected
        case .notConnectable:
            return L10n.Device.notConnectable
        }
    }
    
    var isLoading: Bool {
        switch self {
        case .connecting, .discoveringServices, .interrogating, .disconnecting:
            return true
        case .disconnected, .connected, .notConnectable:
            return false
        }
    }
    
    var canConnect: Bool {
        switch self {
        case .disconnected:
            return true
        case .connecting, .connected, .discoveringServices, .interrogating, .disconnecting, .notConnectable:
            return false
        }
    }
    
    var canDisconnect: Bool {
        switch self {
        case .connected, .discoveringServices, .interrogating:
            return true
        case .disconnected, .connecting, .disconnecting, .notConnectable:
            return false
        }
    }
}

