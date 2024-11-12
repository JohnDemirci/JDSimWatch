//
//  ContentView.swift
//  SimuWatch
//
//  Created by John Demirci on 8/24/24.
//

import SwiftUI

struct ContentView: View {
    @Bindable var manager: SimulatorManager
    let folderClient: FolderClient

    init(
        manager: SimulatorManager,
        folderClient: FolderClient
    ) {
        self.manager = manager
        self.folderClient = folderClient
    }

    var body: some View {
        NavigationSplitView(
            sidebar: {
                List {
                    ForEach(manager.bootedSimulators) { simulator in
                        SidebarButton(simulator: simulator, manager: manager)
                    }
                }
                .listStyle(.sidebar)
            },
            detail: {
                OptionalView(
                    data: manager.selectedSimulator,
                    unwrappedData: { selectedSimulator in
                        SimulatorDetailView(
                            simulator: selectedSimulator,
                            simulatorClient: manager.simulatorClient,
                            folderClient: folderClient,
                            lifecycleObserver: manager.lifecycleObserver
                        )
                    },
                    placeholderView: {
                        NoActiveSimulatorsView(manager: $manager)
                    }
                )
                .toolbar {
                    NavigationLink("Simulator List") {
                        InacvtiveSimulatorsView(
                            manager: manager
                        )
                    }
                }
            }
        )
    }
}

private struct SidebarButton: View {
    let simulator: Simulator
    @Bindable var manager: SimulatorManager

    var body: some View {
        Button(simulator.name ?? "") {
            manager.didSelectSimulator(simulator)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .font(.title3)
        .buttonStyle(.plain)
        .padding(4)
        .background(manager.selectedSimulator == simulator ? .red : .clear)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .contextMenu {
            Button("Shutdown") {
                manager.shutdownSimulator(simulator)
            }
            .alert(item: $manager.failure) { failure in
                Alert(title: Text(failure.description))
            }
        }
    }
}

struct NoActiveSimulatorsView: View {
    @Bindable var manager: SimulatorManager

    init(manager: Bindable<SimulatorManager>) {
        self._manager = manager
    }

    var body: some View {
        VStack {
            ContentUnavailableView("No Active Simulator", systemImage: "tray")
            NavigationLink("Fetch Inactive Simulators") {
                InacvtiveSimulatorsView(
                    manager: manager
                )
            }
            .accessibilityIdentifier("fetchButton")
        }
    }
}
