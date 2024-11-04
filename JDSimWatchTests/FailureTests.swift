//
//  FailureTests.swift
//  JDSimWatchTests
//
//  Created by John Demirci on 11/4/24.
//

import Testing
@testable import JDSimWatch

struct FailureTests {
    @Test("Failure message equal to failure identifier", arguments: [
        "some string",
        "another string",
        "third string"
    ])
    func testIdentifier(arg: String) async throws {
        let failure = Failure.message(arg)
        let secondFailure = Failure.message(arg)

        #expect(failure.description == arg)
        #expect(failure.id == arg)
        #expect(failure.description == failure.id)
        #expect(failure == secondFailure)
    }
}
