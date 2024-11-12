//
//  SimulatorManager.swift
//  JDSimWatch
//
//  Created by John Demirci on 11/11/24.
//

import Combine
import Foundation
import SwiftUI

@Observable
final class SimulatorManager {
    private var observers: [AnyCancellable] = []
    let id: String
    let simulatorClient: SimulatorClient
    let lifecycleObserver: LifecycleObserver

    var failure: Failure?

    var bootedSimulators: [Simulator] = []
    var shutdownSimulators: [Simulator] = []
    var selectedSimulator: Simulator? = nil

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
    func didSelectSimulator(_ simulator: Simulator) {
        self.selectedSimulator = simulator

        if !bootedSimulators.contains(simulator) {
            bootedSimulators.append(simulator)
        }
    }

    func fetchBootedSimulators() {
        switch simulatorClient.fetchBootedSimulators() {
        case .success(let simulators):
            if Set(bootedSimulators) != Set(simulators) {
                self.bootedSimulators = simulators
            }
        case .failure(let error):
            self.failure = .message(error.localizedDescription)
        }
    }

    func fetchShutdownSimulators() {
        switch simulatorClient.fetchShurtdownSimulators() {
        case .success(let simulators):
            if Set(shutdownSimulators) != Set(simulators) {
                self.shutdownSimulators = simulators
            }
        case .failure(let error):
            self.failure = .message(error.localizedDescription)
        }
    }

    func shutdownSimulator(_ simulator: Simulator) {
        switch simulatorClient.shutdownSimulator(simulator: simulator.id) {
        case .success:
            bootedSimulators.removeAll { $0 == simulator }

            if !shutdownSimulators.contains(simulator) {
                shutdownSimulators.append(simulator)
            }
            if selectedSimulator == simulator {
                self.selectedSimulator = bootedSimulators.first
            }

        case .failure(let error):
            self.failure = .message(error.localizedDescription)
        }
    }
}

extension SimulatorManager: LifecycleObservable {
    func didLaunchApplication() {
        self.fetchBootedSimulators()
        self.fetchShutdownSimulators()
    }
    
    func didBecomeActive() {
        self.fetchBootedSimulators()
        self.fetchShutdownSimulators()
    }
}
