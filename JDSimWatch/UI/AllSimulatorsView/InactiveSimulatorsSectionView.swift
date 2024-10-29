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

    var body: some View {
        ForEach(version.devices) { device in
            LabeledContent(device.name) {
                Button(
                    action: {
                        switch shell.openSimulator(uuid: device.uuid) {
                        case .success:
                            manager.fetchSimulators()
                        case .failure(let error):
                            break
                        }
                    },
                    label: {
                        Image(systemName: "play")
                    }
                )
            }
        }
    }
}
