//
//  SignalStrengthCalculator.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import Foundation

enum SignalStrengthCalculator {
    static func getSignalBars(for rssi: Int) -> Int {
        switch rssi {
        case -42...Int.max:
            return 5
        case -54...(-42):
            return 4
        case -66...(-54):
            return 3
        case -79...(-66):
            return 2
        case -90...(-79):
            return 1
        default:
            return 0
        }
    }
}

