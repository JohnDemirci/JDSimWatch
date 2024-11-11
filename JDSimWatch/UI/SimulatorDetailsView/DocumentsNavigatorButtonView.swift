//
//  DocumentsNavigatorButtonView.swift
//  JDSimWatch
//
//  Created by John Demirci on 11/9/24.
//

import SwiftUI

extension SimulatorDetailView {
    struct DocumentsNavigatorButtonView: View {
        @State private var viewManager: ViewManager

        init(environment: ViewManager.Environment) {
            self.viewManager = .init(environment: environment)
        }

        var body: some View {
            ListRowTapableButton("Documents") {
                viewManager.didSelectDocuments()
            }
            .alert(item: $viewManager.failure) {
                Alert(title: Text($0.description))
            }
        }
    }
}

extension SimulatorDetailView.DocumentsNavigatorButtonView {
    @Observable
    final class ViewManager {
        struct Environment {
            let simulator: Simulator_Legacy
            let folderClient: FolderClient
        }

        var failure: Failure?
        private let environment: Environment

        private var simulatorID: String {
            environment.simulator.id
        }

        init(environment: Environment) {
            self.environment = environment
        }

        func didSelectDocuments() {
            switch environment.folderClient.openSimulatorDocuments(simulatorID) {
            case .success:
                break
            case .failure(let error):
                failure = .message(error.localizedDescription)
            }
        }
    }
}
