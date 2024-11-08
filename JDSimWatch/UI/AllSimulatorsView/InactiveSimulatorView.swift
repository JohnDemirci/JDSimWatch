//
//  InactiveSimulatorView.swift
//  SimuWatch
//
//  Created by John Demirci on 8/25/24.
//

import SwiftUI

struct InacvtiveSimulatorsView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var manager: SimulatorManager
    @State private var failure: Failure?
    @State var osVersions: [InactiveSimulatorParser.OSVersion] = []

    var body: some View {
        List {
            InactiveSimulatorsSectionView(
                osVersions: osVersions,
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
            switch manager.simulatorClient.fetchAllSimulators_Legacy() {
            case .success(let osVersions):
                self.osVersions = osVersions
            case .failure(let error):
                failure = .message(error.localizedDescription)
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
