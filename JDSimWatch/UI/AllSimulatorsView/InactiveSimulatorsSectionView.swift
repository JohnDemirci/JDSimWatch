//
//  InactiveSimulatorsSectionView.swift
//  SimuWatch
//
//  Created by John Demirci on 8/25/24.
//

import SwiftUI

struct InactiveSimulatorsSectionView: View {
    @Environment(SimulatorManager.self) private var store
    private let osVersions: [InactiveSimulatorParser.OSVersion]

    init(osVersions: [InactiveSimulatorParser.OSVersion]) {
        self.osVersions = osVersions
    }

    var body: some View {
        ForEach(osVersions) { osVersion in
            Section("\(osVersion.name) \(osVersion.version)") {
                InactiveSimulatorsSectionContentView(version: osVersion)
                    .environment(store)
            }
        }
    }
}

struct InactiveSimulatorsSectionContentView: View {
    @Environment(\.shell) private var shell
    @Environment(SimulatorManager.self) private var store
    private let version: InactiveSimulatorParser.OSVersion

    init(version: InactiveSimulatorParser.OSVersion) {
        self.version = version
    }

    var body: some View {
        ForEach(version.devices) { device in
            LabeledContent(device.name) {
                Button(
                    action: {
                        switch shell.openSimulator(uuid: device.uuid) {
                        case .success:
                            store.fetchSimulators()
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
