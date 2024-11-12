//
//  FetchSimulatorsTest.swift
//  JDSimWatch
//
//  Created by John Demirci on 11/11/24.
//

import Testing
@testable import JDSimWatch

@Suite
struct FetchSimulatorsTest {
    @Test
    func testExample() {
        let data = SimulatorClient.handleFetchSimulators()
        print(data)
    }
}
