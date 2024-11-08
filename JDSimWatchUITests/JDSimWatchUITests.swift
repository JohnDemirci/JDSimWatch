//
//  JDSimWatchUITests.swift
//  JDSimWatchUITests
//
//  Created by John Demirci on 11/8/24.
//

import XCTest
@testable import JDSimWatch

final class JDSimWatchUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    @MainActor
    func testSimulatorToolbarButton() throws {
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
