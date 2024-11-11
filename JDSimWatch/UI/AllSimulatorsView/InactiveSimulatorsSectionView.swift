//
//  InactiveSimulatorsSectionView.swift
//  SimuWatch
//
//  Created by John Demirci on 8/25/24.
//

import Combine
import SwiftUI

struct InactiveSimulatorsSectionView: View {
    let osVersions: [InactiveSimulatorParser.OSVersion]
    @Bindable var manager: SimulatorManager

    var body: some View {
        ForEach(osVersions) { osVersion in
            Section("\(osVersion.name) \(osVersion.version)") {
                InactiveSimulatorsSectionContentView(
                    manager: manager,
                    versionAndSimulators: osVersion,
                    client: manager.simulatorClient
                )
            }
        }
    }
}

private struct InactiveSimulatorsSectionContentView: View {
    @Bindable var manager: SimulatorManager
    @Bindable var viewModel: InactiveSimulatorsSectionContentViewModel

    init(
        manager: SimulatorManager,
        versionAndSimulators: InactiveSimulatorParser.OSVersion,
        client: SimulatorClient
    ) {
        self.manager = manager
        self.viewModel = .init(
            versionAndSimulators: versionAndSimulators,
            client: client
        )
    }

    var body: some View {
        ForEach(viewModel.versionAndSimulators.devices) { device in
            LabeledContent(device.name) {
                HStack {
                    Button(
                        action: {
                            viewModel.openSimulator(device.uuid)
                        },
                        label: {
                            Image(systemName: "play")
                        }
                    )

                    Button("Delete") {
                        viewModel.deleteSimulator(device.uuid)
                        manager.fetchSimulators()
                    }
                }
            }
            .alert(item: $viewModel.failure) {
                Alert(title: Text($0.description))
            }
            .onReceive(viewModel.didOpenPublisher) {
                manager.fetchSimulators()
            }
        }
    }
}

@Observable
private final class InactiveSimulatorsSectionContentViewModel {
    let versionAndSimulators: InactiveSimulatorParser.OSVersion
    let client: SimulatorClient
    var failure: Failure?

    private let didOpenSubject = PassthroughSubject<Void, Never>()

    var didOpenPublisher: AnyPublisher<Void, Never> {
        didOpenSubject.eraseToAnyPublisher()
    }

    init(
        versionAndSimulators: InactiveSimulatorParser.OSVersion,
        client: SimulatorClient
    ) {
        self.versionAndSimulators = versionAndSimulators
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
