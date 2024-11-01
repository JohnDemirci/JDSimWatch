//
//  InactiveSimulatorsSectionView.swift
//  SimuWatch
//
//  Created by John Demirci on 8/25/24.
//

import SwiftUI

struct InactiveSimulatorsSectionView: View {
   let osVersions: [InactiveSimulatorParser.OSVersion]
    @Bindable var manager: SimulatorManager

    var body: some View {
        ForEach(osVersions) { osVersion in
            Section("\(osVersion.name) \(osVersion.version)") {
                InactiveSimulatorsSectionContentView(
                    version: osVersion,
                    manager: manager
                )
            }
        }
    }
}

struct InactiveSimulatorsSectionContentView: View {
    @Environment(\.shell) private var shell
    let version: InactiveSimulatorParser.OSVersion
    @Bindable var manager: SimulatorManager
    @State private var failure: Failure?

    var body: some View {
        ForEach(version.devices) { device in
            LabeledContent(device.name) {
                Button(
                    action: {
                        switch shell.execute(.openSimulator(device.uuid)) {
                        case .success:
                            manager.fetchSimulators()
                        case .failure(let error):
                            failure = .message(error.localizedDescription)
                            break
                        }
                    },
                    label: {
                        Image(systemName: "play")
                    }
                )
            }
            .alert(item: $failure) {
                Alert(title: Text($0.description))
            }
        }
    }
}
