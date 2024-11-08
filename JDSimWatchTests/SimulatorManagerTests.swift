//
//  SimulatorManagerTests.swift
//  JDSimWatch
//
//  Created by John Demirci on 11/7/24.
//

import Testing
@testable import JDSimWatch

@Suite("Simulator Manager")
struct SimulatorManagerTests {
    @Test
    func fetchBootedSimulatorsSuccess() async throws {
        let simulator = Simulator_Legacy(id: "123", name: "iOS Simulator")
        let simulatorClient = SimulatorClient.testing
            .mutate(_fetchBootedSimulators_Legacy: {
                return .success([simulator])
            })

        let manager = SimulatorManager(simulatorClient: simulatorClient)

        manager.fetchSimulators()

        #expect(manager.selectedSimulator == simulator)
        #expect(manager.simulators == [simulator])
    }

    @Test
    func fetchBootedSimulatorsFailure() async throws {
        let error = Failure.message("error")

        let simulatorClient = SimulatorClient.testing
            .mutate(_fetchBootedSimulators_Legacy: {
                return .failure(error)
            })

        let manager = SimulatorManager(simulatorClient: simulatorClient)

        manager.fetchSimulators()

        #expect(manager.selectedSimulator == nil)
        #expect(manager.simulators == [])
        #expect(manager.failure != nil)
    }

    @Test
    func didSelectSimulator() async throws {
        let manager = SimulatorManager(simulatorClient: .testing)

        let simulator = Simulator_Legacy(id: "123", name: "simulator")

        manager.didSelectSimulator(simulator)
        #expect(manager.selectedSimulator == simulator)
        #expect(manager.simulators == [simulator])
    }

    @Test
    func shutdownSimulatorSuccess() async throws {
        let client = SimulatorClient.testing
            .mutate(_shutdownSimulator: { _ in
                return .success(())
            })

        let manager = SimulatorManager(simulatorClient: client)
        let simulator = Simulator_Legacy(id: "123", name: "simulator")

        // setup
        manager.simulators = [simulator]
        manager.didSelectSimulator(simulator)

        // action
        manager.shutdownSimulator(simulator)

        // assert
        #expect(manager.simulators.isEmpty)
        #expect(manager.selectedSimulator == nil)
    }

    @Test
    func shutdownSimulatorFailure() async throws {
        let client = SimulatorClient.testing
            .mutate(_shutdownSimulator: { _ in
                return .failure(Failure.message("error"))
            })

        let manager = SimulatorManager(simulatorClient: client)
        let simulator = Simulator_Legacy(id: "123", name: "simulator")

        // setup
        manager.simulators = [simulator]
        manager.didSelectSimulator(simulator)

        // action
        manager.shutdownSimulator(simulator)

        // assert
        #expect(manager.selectedSimulator == simulator)
        #expect(manager.simulators == [simulator])
    }
}
