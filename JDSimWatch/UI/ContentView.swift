//
//  ContentView.swift
//  SimuWatch
//
//  Created by John Demirci on 8/24/24.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.shell) private var shell
    @Environment(SimulatorManager.self) private var store

    var body: some View {
        NavigationSplitView(
            sidebar: {
                List {
                    ForEach(store.simulators) { simulator in
                        Button(simulator.name) {
                            store.didSelectSimulator(simulator)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(.title3)
                        .buttonStyle(.plain)
                        .padding(4)
                        .background(store.selectedSimulator == simulator ? .red : .clear)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .contextMenu {
                            Button("Shutdown") {
                                store.shutdownSimulator(simulator)
                            }
                        }
                    }
                }
                .listStyle(.sidebar)
            },
            detail: {
                Group {
                    if let selectedSimulator = store.selectedSimulator {
                        SimulatorDetailView(simulator: selectedSimulator)
                    } else {
                        VStack {
                            ContentUnavailableView("No Active Simulator", systemImage: "tray")
                            NavigationLink("Fetch Inactive Simulators") {
                                InacvtiveSimulatorsView()
                                    .environment(store)
                            }
                        }
                    }
                }
                .toolbar {
                    NavigationLink(
                        destination: {
                            InacvtiveSimulatorsView()
                                .environment(store)
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
