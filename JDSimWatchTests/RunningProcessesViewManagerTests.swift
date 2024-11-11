//
//  RunningProcessesViewManagerTests.swift
//  JDSimWatch
//
//  Created by John Demirci on 11/10/24.
//

import Testing
@testable import JDSimWatch

@Suite
struct RunningProcessesViewManagerTests {
    @Test
    func fetchRunningProcesses() throws {
        let simulator = Simulator_Legacy(id: "some-id", name: "some-name")

        let processInfos: [ProcessInfo] = [
            .init(pid: "one", status: "one", label: "one"),
            .init(pid: "two", status: "two", label: "two"),
            .init(pid: "three", status: "three", label: "three"),
            .init(pid: "four", status: "four", label: "four")
        ]

        let client = SimulatorClient.testing
            .mutate(_activeProcesses: { _ in
                return .success(processInfos)
            })

        let manager = RunningProcessesView.ViewManager(
            environment: .init(
                simulatorClient: client,
                lifecycleObserver: .init(),
                simulator: simulator
            )
        )

        manager.fetchRunningProcesses()

        #expect(manager.state.processes == processInfos)
        #expect(manager.state.failure == nil)
        #expect(manager.state.filter == "")
    }

    @Test
    func fetchRunningProcessesFailure() throws {
        let simulator = Simulator_Legacy(id: "some-id", name: "some-name")

        let client = SimulatorClient.testing
            .mutate(_activeProcesses: { _ in
                return .failure(Failure.message("some error"))
            })

        let manager = RunningProcessesView.ViewManager(
            environment: .init(
                simulatorClient: client,
                lifecycleObserver: .init(),
                simulator: simulator
            )
        )

        manager.fetchRunningProcesses()

        #expect(manager.state.failure != nil)
        #expect(manager.state.processes.isEmpty)
    }

    @Test
    func lifecycleDidLaunchApplicationFailure() {
        let simulator = Simulator_Legacy(id: "some-id", name: "some-name")

        let client = SimulatorClient.testing
            .mutate(_activeProcesses: { _ in
                return .failure(Failure.message("some error"))
            })

        let manager = RunningProcessesView.ViewManager(
            environment: .init(
                simulatorClient: client,
                lifecycleObserver: .init(),
                simulator: simulator
            )
        )

        manager.didLaunchApplication()
        #expect(manager.state.failure != nil)
        #expect(manager.state.processes.isEmpty)
    }

    @Test
    func lifecycleDidActivateAlicationFailure() {
        let simulator = Simulator_Legacy(id: "some-id", name: "some-name")

        let client = SimulatorClient.testing
            .mutate(_activeProcesses: { _ in
                return .failure(Failure.message("some error"))
            })

        let manager = RunningProcessesView.ViewManager(
            environment: .init(
                simulatorClient: client,
                lifecycleObserver: .init(),
                simulator: simulator
            )
        )

        manager.didBecomeActive()
        #expect(manager.state.failure != nil)
        #expect(manager.state.processes.isEmpty)
    }

    @Test
    func lifecycleDidLaunchApplicationSuccess() {
        let simulator = Simulator_Legacy(id: "some-id", name: "some-name")

        let client = SimulatorClient.testing
            .mutate(_activeProcesses: { _ in
                return .success([.init(pid: "one", status: "one", label: "one")])
            })

        let manager = RunningProcessesView.ViewManager(
            environment: .init(
                simulatorClient: client,
                lifecycleObserver: .init(),
                simulator: simulator
            )
        )

        manager.didLaunchApplication()
        #expect(!manager.state.processes.isEmpty)
        #expect(manager.state.failure == nil)
    }

    @Test
    func lifecycleDidActivateApplicationSuccess() {
        let simulator = Simulator_Legacy(id: "some-id", name: "some-name")

        let client = SimulatorClient.testing
            .mutate(_activeProcesses: { _ in
                return .success([.init(pid: "one", status: "one", label: "one")])
            })

        let manager = RunningProcessesView.ViewManager(
            environment: .init(
                simulatorClient: client,
                lifecycleObserver: .init(),
                simulator: simulator
            )
        )

        manager.didBecomeActive()
        #expect(!manager.state.processes.isEmpty)
        #expect(manager.state.failure == nil)
    }
}
