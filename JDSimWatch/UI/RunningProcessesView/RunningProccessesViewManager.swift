//
//  RunningProccessesViewManager.swift
//  JDSimWatch
//
//  Created by John Demirci on 11/9/24.
//

import SwiftUI

extension RunningProcessesView {
    @Observable
    final class ViewManager {
        struct Environment {
            let simulatorClient: SimulatorClient
            let lifecycleObserver: LifecycleObserver
            let simulator: Simulator_Legacy
        }

        struct ViewState: Hashable {
            var processes: [ProcessInfo] = []
            var filter: String = ""
            var failure: Failure?

            var filteredProcesses: [ProcessInfo] {
                if filter.isEmpty { return processes }

                return processes.filter {
                    $0.label.localizedCaseInsensitiveContains(filter)
                }
            }
        }

        private let environment: Environment
        let id: String
        var state: ViewState = .init()

        init(
            environment: Environment,
            id: String = UUID().uuidString
        ) {
            self.environment = environment
            self.id = id

            self.environment.lifecycleObserver.register(self)
        }

        deinit {
            self.environment.lifecycleObserver.removeObserver(self)
        }

        func fetchRunningProcesses() {
            switch environment.simulatorClient.activeProcesses(simulator: environment.simulator.id) {
            case .success(let processInfos):
                self.state.processes = processInfos

            case .failure(let error):
                self.state.failure = .message(error.localizedDescription)
            }
        }
    }
}

extension RunningProcessesView.ViewManager: LifecycleObservable {
    func didLaunchApplication() {
        fetchRunningProcesses()
    }
    
    func didBecomeActive() {
        fetchRunningProcesses()
    }
}
