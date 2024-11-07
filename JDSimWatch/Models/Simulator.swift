//
//  Simulator.swift
//  SimuWatch
//
//  Created by John Demirci on 8/25/24.
//

import Combine
import Foundation
import SwiftUI

struct Simulator_Legacy: Hashable, Identifiable {
    let id: String
    let name: String
}

@Observable
final class SimulatorManager {
    private var observers: [AnyCancellable] = []
    var simulators: [Simulator_Legacy] = []
    var selectedSimulator: Simulator_Legacy? = nil
    let client: Client

    var failure: Failure?

    init(client: Client = .live) {
        self.client = client
        registerObservers()
    }

    func registerObservers() {
        NSWorkspace
            .shared
            .notificationCenter
            .publisher(for: NSWorkspace.didLaunchApplicationNotification)
            .sink { [weak self] _ in
                self?.fetchSimulators()
            }
            .store(in: &observers)

        NSWorkspace
            .shared
            .notificationCenter
            .publisher(for: NSWorkspace.didActivateApplicationNotification)
            .sink { [weak self] _ in
                self?.fetchSimulators()
            }
            .store(in: &observers)
    }
}

extension SimulatorManager {
    func didSelectSimulator(_ simulator: Simulator_Legacy) {
        self.selectedSimulator = simulator

        if !self.simulators.contains(simulator) {
            self.simulators.append(simulator)
        }
    }

    func fetchSimulators() {
        switch client.fetchBootedSimulators_Legacy() {
        case .success(let simulators):
            self.simulators = simulators
            self.selectedSimulator = self.simulators.first

        case .failure(let error):
            failure = .message(error.localizedDescription)
        }
    }

    func shutdownSimulator(_ simulator: Simulator_Legacy) {
        switch client.shutdownSimulator(simulator: simulator.id) {
        case .success:
            simulators.removeAll { $0 == simulator }
            if selectedSimulator == simulator {
                selectedSimulator = simulators.first
            }

        case .failure(let error):
            self.failure = .message(error.localizedDescription)
        }
    }
}
