//
//  InactiveSimulatorView.swift
//  SimuWatch
//
//  Created by John Demirci on 8/25/24.
//

import SwiftUI

struct InacvtiveSimulatorsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.shell) private var shell
    @Environment(SimulatorManager.self) private var store
    @State private var parser = InactiveSimulatorParser()

    var body: some View {
        List {
            InactiveSimulatorsSectionView(osVersions: parser.osVersionsAndDevices)
                .environment(store)
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(
                    action: { dismiss() },
                    label: {
                        Image(systemName: "chevron.left")
                    }
                )
            }
        }
        .onAppear {
            // fetch the inactive simulators
            let result = shell.execute(
                command: .fetchAllSimulators
            )

            guard case .success(let output) = result else {
                return
            }

            print(output)

            parser.parseDeviceInfo(output)
        }
        .navigationTitle("Simulator List")
    }
}
