//
//  InactiveSimulatorsViewModelTests.swift
//  JDSimWatch
//
//  Created by John Demirci on 11/8/24.
//

import Testing
@testable import JDSimWatch

struct InactiveSimulatorsViewModelTests {
    @Test
    func testFetchAllSimulatorsSuccess() async throws {
        let osAndSimulators: [InactiveSimulatorParser.OSVersion] = [
            .init(
                name: "name",
                version: "version",
                devices: [
                    .init(
                        name: "device1",
                        uuid: "uuid1",
                        state: "Shutdown"
                    ),
                    .init(
                        name: "device2",
                        uuid: "uuid2",
                        state: "Shutdown"
                    ),
                    .init(
                        name: "device3",
                        uuid: "uuid3",
                        state: "Shutdown"
                    )
                ]
            )
        ]

        let client = SimulatorClient.testing
            .mutate(
                _fetchAllSimulators_Legacy: {
                    return .success(osAndSimulators)
            })

        let viewModel = InactiveSimulatorViewModel(
            simulatorClient: client
        )

        viewModel.fetchAllSimulators()

        #expect(viewModel.osAndSimulators == osAndSimulators)
    }

    @Test
    func testFetchAllSimulatorsFailure() async throws {
        let client = SimulatorClient.testing
            .mutate(_fetchAllSimulators_Legacy: {
                return .failure(Failure.message("error"))
            })

        let viewModel = InactiveSimulatorViewModel(simulatorClient: client)

        viewModel.fetchAllSimulators()

        #expect(viewModel.failure != nil)
    }
}
