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
    @State private var parser = InactiveSimulatorParser()
    @Bindable var manager: SimulatorManager
    @State private var failure: Failure?

    var body: some View {
        List {
            InactiveSimulatorsSectionView(
                osVersions: parser.osVersionsAndDevices,
                manager: manager
            )
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
            let result = shell.execute(.fetchAllSimulators)

            switch result {
            case .success(let maybeOutput):
                guard let output = maybeOutput else {
                    failure = .message("No simulators found")
                    return
                }

				dump(output)
                parser.parseDeviceInfo(output)
                
            case .failure(let error):
                self.failure = .message(error.localizedDescription)
            }
        }
        .alert(item: $manager.failure) {
            Alert(title: Text($0.description))
        }
        .alert(item: $failure) {
            Alert(title: Text($0.description))
        }
        .navigationTitle("Simulator List")
    }
}
