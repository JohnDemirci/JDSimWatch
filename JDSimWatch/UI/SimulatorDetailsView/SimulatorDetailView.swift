//
//  SimulatorDetailView.swift
//  SimuWatch
//
//  Created by John Demirci on 8/24/24.
//

import SwiftUI

struct SimulatorDetailView: View {
    private let simulator: Simulator_Legacy
    private let client: Client

    init(
        simulator: Simulator_Legacy,
        client: Client = .live
    ) {
        self.simulator = simulator
        self.client = client
    }

    var body: some View {
        List {
            ProcessesNavigationLink(simulator: simulator, client: client)
            GoToDocumentsView(simulator: simulator)
            EraseContentsView(simulator: simulator, client: client)
            InstalledApplicationsButtonView(
                simulator: simulator,
                client: client
            )
        }
		.navigationTitle(simulator.name)
    }
}

private struct GoToDocumentsView: View {
	let simulator: Simulator_Legacy
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
        let folderPath = "~/Library/Developer/CoreSimulator/Devices/\(simulator.id)/data/Documents/"
        let expandedPath = NSString(string: folderPath).expandingTildeInPath
        let fileURL = URL(fileURLWithPath: expandedPath)

        if !NSWorkspace.shared.open(fileURL) {
            failure = .message("Could not open \(fileURL)")
        }
    }
}

private struct ProcessesNavigationLink: View {
	let simulator: Simulator_Legacy
    let client: Client

	var body: some View {
		NavigationLink(
			destination: {
                RunningProcessesView(
                    simulator: simulator,
                    client: client
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
    let client: Client
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
        switch client.eraseContents(simulator: simulator.id) {
        case .success:
            break
        case .failure(let error):
            self.failure = .message(error.localizedDescription)
        }
	}
}

private struct InstalledApplicationsButtonView: View {
	let simulator: Simulator_Legacy
    let client: Client

	var body: some View {
		NavigationLink(
            destination: {
                InstalledApplicationsView(
                    simulator: simulator,
                    client: client
                )
            },
			label: {
				Text("Installed Applications")
			}
		)
		.buttonStyle(PlainButtonStyle())
	}
}
