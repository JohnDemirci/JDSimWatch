//
//  SuccessTests.swift
//  JDSimWatch
//
//  Created by John Demirci on 11/4/24.
//

import Testing
@testable import JDSimWatch

struct SuccessTests {
    @Test("Testing the Success Enum", arguments: [
        "one",
        "two",
        "three"
    ])
    func testSuccess(arg: String) async throws {
        let successOne = Success.message(arg, nil)

        #expect(successOne.description == arg)
        #expect(successOne.id == arg)
        #expect(successOne.description == successOne.id)
    }
}
