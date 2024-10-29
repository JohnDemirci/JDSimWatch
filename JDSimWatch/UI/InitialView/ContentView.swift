//
//  ContentView.swift
//  SimuWatch
//
//  Created by John Demirci on 8/24/24.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.shell) private var shell

    @Bindable var manager: SimulatorManager

    var body: some View {
        NavigationSplitView(
            sidebar: {
                List {
                    ForEach(manager.simulators) { simulator in
                        SidebarButton(simulator: simulator, manager: manager)
                    }
                }
                .listStyle(.sidebar)
            },
            detail: {
                OptionalView(
                    data: manager.selectedSimulator,
                    unwrappedData: { selectedSimulator in
                        SimulatorDetailView(simulator: selectedSimulator)
                    },
                    placeholderView: {
                        NoActiveSimulatorsView(manager: manager)
                    }
                )
                .toolbar {
                    NavigationLink("Simulators") {
                        InacvtiveSimulatorsView(manager: manager)
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
        Button(simulator.name) {
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
        }
    }
}

struct NoActiveSimulatorsView: View {
    @Bindable var manager: SimulatorManager

    var body: some View {
        VStack {
            ContentUnavailableView("No Active Simulator", systemImage: "tray")
            NavigationLink("Fetch Inactive Simulators") {
                InacvtiveSimulatorsView(manager: manager)
            }
        }
    }
}
