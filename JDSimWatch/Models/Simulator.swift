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
    let id: String
    var simulators: [Simulator_Legacy] = []
    var selectedSimulator: Simulator_Legacy? = nil
    let simulatorClient: SimulatorClient
    let lifecycleObserver: LifecycleObserver

    var failure: Failure?

    init(
        simulatorClient: SimulatorClient = .live,
        lifecycleObserver: LifecycleObserver,
        id: String = UUID().uuidString
    ) {
        self.simulatorClient = simulatorClient
        self.id = id
        self.lifecycleObserver = lifecycleObserver

        lifecycleObserver.register(self)
    }

    deinit {
        lifecycleObserver.removeObserver(self)
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
        switch simulatorClient.fetchBootedSimulators_Legacy() {
        case .success(let simulators):
            self.simulators = simulators
            self.selectedSimulator = self.simulators.first

        case .failure(let error):
            failure = .message(error.localizedDescription)
        }
    }

    func shutdownSimulator(_ simulator: Simulator_Legacy) {
        switch simulatorClient.shutdownSimulator(simulator: simulator.id) {
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

extension SimulatorManager: LifecycleObservable {
    func didLaunchApplication() {
        self.fetchSimulators()
    }
    
    func didBecomeActive() {
        self.fetchSimulators()
    }
}
