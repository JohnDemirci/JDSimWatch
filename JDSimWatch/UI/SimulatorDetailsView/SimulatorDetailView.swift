//
//  SimulatorDetailView.swift
//  SimuWatch
//
//  Created by John Demirci on 8/24/24.
//

import SwiftUI

struct SimulatorDetailView: View {
	@Environment(\.shell) private var shell
    private let simulator: Simulator

    init(simulator: Simulator) {
        self.simulator = simulator
    }

    var body: some View {
        List {
            ProcessesNavigationLink(simulator: simulator)
            GoToDocumentsView(simulator: simulator)
            EraseContentsView(simulator: simulator)
            InstalledApplicationsButtonView(simulator: simulator)
        }
		.navigationTitle(simulator.name)
    }
}

private struct GoToDocumentsView: View {
	let simulator: Simulator

	var body: some View {
        ListRowTapableButton("Documents") {
            goToDocuments()
        }
	}
}

private extension GoToDocumentsView {
    func goToDocuments() {
        let folderPath = "~/Library/Developer/CoreSimulator/Devices/\(simulator.id)/data/Documents/"
        let expandedPath = NSString(string: folderPath).expandingTildeInPath
        let fileURL = URL(fileURLWithPath: expandedPath)
        NSWorkspace.shared.open(fileURL)
    }
}

private struct ProcessesNavigationLink: View {
	let simulator: Simulator

	var body: some View {
		NavigationLink(
			destination: {
				RunningProcessesView(simulator: simulator)
			},
			label: {
                Text("Processes")
			}
		)
		.buttonStyle(PlainButtonStyle())
	}
}

private struct EraseContentsView: View {
	@Environment(\.shell) private var shell
	let simulator: Simulator

	var body: some View {
        ListRowTapableButton("Erase Contents") {
            eraseSimulator()
        }
	}
}

extension EraseContentsView {
	func eraseSimulator() {
        let result = shell.execute(.eraseContents(simulator.id))

        switch result {
        case .success:
            // TODO: - handle
            break
        case .failure(let error):
            dump(error.localizedDescription)
        }
	}
}

private struct InstalledApplicationsButtonView: View {
	let simulator: Simulator

	var body: some View {
		NavigationLink(
			destination: { InstalledApplicationsView(simulator: simulator) },
			label: {
				Text("Installed Applications")
			}
		)
		.buttonStyle(PlainButtonStyle())
	}
}
