//
//  InactiveSimulatorsSectionView.swift
//  SimuWatch
//
//  Created by John Demirci on 8/25/24.
//

import Combine
import SwiftUI

struct InactiveSimulatorsSectionView: View {
    @Bindable var manager: SimulatorManager

    var body: some View {
        ForEach(manager.shutdownSimulators) { simulator in
            InactiveSimulatorsSectionContentView(
                manager: manager,
                simulator: simulator,
                client: manager.simulatorClient
            )
        }
    }
}

private struct InactiveSimulatorsSectionContentView: View {
    @Bindable var manager: SimulatorManager
    @Bindable var viewModel: InactiveSimulatorsSectionContentViewModel

    init(
        manager: SimulatorManager,
        simulator: Simulator,
        client: SimulatorClient
    ) {
        self.manager = manager
        self.viewModel = .init(
            simulator: simulator,
            client: client
        )
    }

    var body: some View {
        LabeledContent(viewModel.simulator.name ?? "") {
            HStack {
                Button(
                    action: {
                        viewModel.openSimulator(viewModel.simulator.id)
                    },
                    label: {
                        Image(systemName: "play")
                    }
                )

                Button("Delete") {
                    viewModel.deleteSimulator(viewModel.simulator.id)
                    manager.fetchBootedSimulators()
                    manager.fetchShutdownSimulators()
                }
            }
        }
        .alert(item: $viewModel.failure) {
            Alert(title: Text($0.description))
        }
        .onReceive(viewModel.didOpenPublisher) {
            manager.fetchBootedSimulators()
            manager.fetchShutdownSimulators()
        }
    }
}

@Observable
private final class InactiveSimulatorsSectionContentViewModel {
    let simulator: Simulator
    let client: SimulatorClient
    var failure: Failure?

    private let didOpenSubject = PassthroughSubject<Void, Never>()

    var didOpenPublisher: AnyPublisher<Void, Never> {
        didOpenSubject.eraseToAnyPublisher()
    }

    init(
        simulator: Simulator,
        client: SimulatorClient
    ) {
        self.simulator = simulator
        self.client = client
    }

    func openSimulator(_ id: String) {
        switch client.openSimulator(simulator: id) {
        case .success:
            didOpenSubject.send(())

        case .failure(let error):
            failure = .message(error.localizedDescription)
        }
    }

    func deleteSimulator(_ id: String) {
        switch client.deleteSimulator(simulator: id) {
        case .success:
            break

        case .failure(let error):
            failure = .message(error.localizedDescription)
        }
    }
}
