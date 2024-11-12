//
//  EraseSimulatorContentsView.swift
//  JDSimWatch
//
//  Created by John Demirci on 11/9/24.
//

import SwiftUI

struct EraseSimulatorContentsView: View {
    @State private var viewManager: ViewManager

    init(environment: ViewManager.Environment) {
        self.viewManager = .init(environment: environment)
    }

    var body: some View {
        ListRowTapableButton("Erase Contents") {
            viewManager.didSelectEraseSimulator()
        }
        .alert(item: $viewManager.state.failure) {
            Alert(title: Text($0.description))
        }
    }
}

extension EraseSimulatorContentsView {
    @Observable
    final class ViewManager {
        struct Environment {
            let simulator: Simulator
            let simulatorClient: SimulatorClient
        }

        struct State: Hashable {
            var failure: Failure?
        }

        private let environment: Environment
        var state = State()

        init(environment: Environment) {
            self.environment = environment
        }

        func didSelectEraseSimulator() {
            switch environment.simulatorClient.eraseContents(simulator: environment.simulator.id) {
            case .success:
                break

            case .failure(let error):
                self.state.failure = .message(error.localizedDescription)
            }
        }
    }
}
