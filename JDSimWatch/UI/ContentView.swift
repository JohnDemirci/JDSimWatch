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
                .listStyle(.sidebar)
            },
            detail: {
                Group {
                    if let selectedSimulator = manager.selectedSimulator {
                        SimulatorDetailView(simulator: selectedSimulator)
                    } else {
                        VStack {
                            ContentUnavailableView("No Active Simulator", systemImage: "tray")
                            NavigationLink("Fetch Inactive Simulators") {
                                InacvtiveSimulatorsView(manager: manager)
                            }
                        }
                    }
                }
                .toolbar {
                    NavigationLink(
                        destination: {
                            InacvtiveSimulatorsView(manager: manager)
                        },
                        label: {
                            Text("Simulators")
                        }
                    )
                }
            }
        )
    }
}
