//
//  SimulatorDetailView.swift
//  SimuWatch
//
//  Created by John Demirci on 8/24/24.
//

import SwiftUI

struct SimulatorDetailView: View {
    private let simulator: Simulator_Legacy
    private let simulatorClient: SimulatorClient
    private let folderClient: FolderClient

    init(
        simulator: Simulator_Legacy,
        simulatorClient: SimulatorClient = .live,
        folderClient: FolderClient = .live
    ) {
        self.simulator = simulator
        self.simulatorClient = simulatorClient
        self.folderClient = folderClient
    }

    var body: some View {
        List {
            ProcessesNavigationLink(simulator: simulator, simulatorClient: simulatorClient)
            GoToDocumentsView(simulator: simulator, folderClient: folderClient)
            EraseContentsView(simulator: simulator, simulatorClient: simulatorClient)
            InstalledApplicationsButtonView(
                simulator: simulator,
                simulatorClient: simulatorClient,
                folderClient: folderClient
            )
        }
		.navigationTitle(simulator.name)
    }
}

private struct GoToDocumentsView: View {
	let simulator: Simulator_Legacy
    let folderClient: FolderClient
    @State private var failure: Failure?

	var body: some View {
        ListRowTapableButton("Documents") {
            goToDocuments()
        }
        .alert(item: $failure) {
            Alert(title: Text($0.description))
        }
	}
}

private extension GoToDocumentsView {
    func goToDocuments() {
        switch folderClient.openSimulatorDocuments(simulator.id) {
        case .success:
            break
        case .failure(let error):
            failure = .message(error.localizedDescription)
        }
    }
}

private struct ProcessesNavigationLink: View {
	let simulator: Simulator_Legacy
    let simulatorClient: SimulatorClient

	var body: some View {
		NavigationLink(
			destination: {
                RunningProcessesView(
                    simulator: simulator,
                    simulatorClient: simulatorClient
                )
			},
			label: {
                Text("Processes")
			}
		)
		.buttonStyle(PlainButtonStyle())
	}
}

private struct EraseContentsView: View {
	let simulator: Simulator_Legacy
    let simulatorClient: SimulatorClient
    @State private var failure: Failure?

	var body: some View {
        ListRowTapableButton("Erase Contents") {
            eraseSimulator()
        }
        .alert(item: $failure) {
            Alert(title: Text($0.description))
        }
	}
}

extension EraseContentsView {
	func eraseSimulator() {
        switch simulatorClient.eraseContents(simulator: simulator.id) {
        case .success:
            break
        case .failure(let error):
            self.failure = .message(error.localizedDescription)
        }
	}
}

private struct InstalledApplicationsButtonView: View {
	let simulator: Simulator_Legacy
    let simulatorClient: SimulatorClient
    let folderClient: FolderClient

	var body: some View {
		NavigationLink(
            destination: {
                InstalledApplicationsView(
                    simulator: simulator,
                    simulatorClient: simulatorClient,
                    folderClient: folderClient
                )
            },
			label: {
				Text("Installed Applications")
			}
		)
		.buttonStyle(PlainButtonStyle())
	}
}
