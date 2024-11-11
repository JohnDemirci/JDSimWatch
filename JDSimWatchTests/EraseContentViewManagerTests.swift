//
//  EraseContentViewManagerTests.swift
//  JDSimWatch
//
//  Created by John Demirci on 11/10/24.
//

import Testing
@testable import JDSimWatch

@Suite
struct EraseContentViewManagerTests {
    typealias ViewManager = EraseSimulatorContentsView.ViewManager

    @Test
    func eraseSuccess() {
        let simulator = Simulator_Legacy(id: "one", name: "one")
        let client = SimulatorClient.testing
            .mutate(_eraseContentAndSettings: { _ in
                return .success(())
            })
        let viewManager = ViewManager(
            environment: .init(
                simulator: simulator,
                simulatorClient: client
            )
        )

        viewManager.didSelectEraseSimulator()

        #expect(viewManager.state.failure == nil)
    }

    @Test
    func eraseFailure() {
        let simulator = Simulator_Legacy(id: "one", name: "one")
        let client = SimulatorClient.testing
            .mutate(_eraseContentAndSettings: { _ in
                return .failure(Failure.message("something"))
            })

        let viewManager = ViewManager(
            environment: .init(
                simulator: simulator,
                simulatorClient: client
            )
        )

        viewManager.didSelectEraseSimulator()

        #expect(viewManager.state.failure != nil)
    }
}

