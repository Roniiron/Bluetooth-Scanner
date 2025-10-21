//
//  Bluetooth_ScannerUITestsLaunchTests.swift
//  Bluetooth ScannerUITests
//
//  Created by Roni on 05. 08. 2025.
//

import XCTest

final class Bluetooth_ScannerUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
