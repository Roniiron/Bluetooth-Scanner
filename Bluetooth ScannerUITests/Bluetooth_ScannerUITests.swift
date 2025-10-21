//
//  Bluetooth_ScannerUITests.swift
//  Bluetooth ScannerUITests
//
//  Created by Roni on 05. 08. 2025.
//

import XCTest

final class Bluetooth_ScannerUITests: XCTestCase {

    override func setUpWithError() throws {

        continueAfterFailure = false

    }

    override func tearDownWithError() throws {

    }

    @MainActor
    func testExample() throws {

        let app = XCUIApplication()
        app.launch()

    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {

            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
