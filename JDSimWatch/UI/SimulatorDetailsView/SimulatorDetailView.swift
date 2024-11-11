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
    private let lifecycleObserver: LifecycleObserver

    init(
        simulator: Simulator_Legacy,
        simulatorClient: SimulatorClient = .live,
        folderClient: FolderClient = .live,
        lifecycleObserver: LifecycleObserver
    ) {
        self.simulator = simulator
        self.simulatorClient = simulatorClient
        self.folderClient = folderClient
        self.lifecycleObserver = lifecycleObserver
    }

    var body: some View {
        List {
            ProcessesNavigationLink(
                simulator: simulator,
                simulatorClient: simulatorClient,
                observer: lifecycleObserver
            )

            DocumentsNavigatorButtonView(
                environment: .init(
                    simulator: simulator,
                    folderClient: folderClient
                )
            )

            EraseSimulatorContentsView(
                environment: .init(
                    simulator: simulator,
                    simulatorClient: simulatorClient
                )
            )

            InstalledApplicationsButtonView(
                simulator: simulator,
                simulatorClient: simulatorClient,
                folderClient: folderClient
            )
        }
		.navigationTitle(simulator.name)
    }
}

private struct ProcessesNavigationLink: View {
	let simulator: Simulator_Legacy
    let simulatorClient: SimulatorClient
    let observer: LifecycleObserver

	var body: some View {
		NavigationLink(
			destination: {
                RunningProcessesView(
                    environment: .init(
                        simulatorClient: simulatorClient,
                        lifecycleObserver: observer,
                        simulator: simulator
                    )
                )
			},
			label: {
                Text("Processes")
			}
		)
		.buttonStyle(PlainButtonStyle())
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
