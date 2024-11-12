//
//  InactiveSimulatorView.swift
//  SimuWatch
//
//  Created by John Demirci on 8/25/24.
//

import SwiftUI

struct InacvtiveSimulatorsView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var manager: SimulatorManager

    init(manager: SimulatorManager) {
        self.manager = manager
    }

    var body: some View {
        List {
            InactiveSimulatorsSectionView(manager: manager)
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(
                    action: { dismiss() },
                    label: {
                        Image(systemName: "chevron.left")
                    }
                )
            }
        }
        .navigationTitle("Simulator List")
    }
}

@Observable
final class InactiveSimulatorViewModel {
    let simulatorClient: SimulatorClient
    var failure: Failure?
    var osAndSimulators: [InactiveSimulatorParser.OSVersion] = []

    init(simulatorClient: SimulatorClient) {
        self.simulatorClient = simulatorClient
    }

    func fetchAllSimulators() {
        switch simulatorClient.fetchAllSimulators_Legacy() {
        case .success(let osAndSimulators):
            self.osAndSimulators = osAndSimulators

        case .failure(let error):
            self.failure = .message(error.localizedDescription)
        }
    }
}
