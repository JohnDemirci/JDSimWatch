//
//  InstalledApplicationsview.swift
//  JDSimWatch
//
//  Created by John Demirci on 9/9/24.
//

import Foundation
import SwiftUI

struct InstalledApplicationsView: View {
    @Environment(\.dismiss) private var dismiss
	@Bindable private var viewModel = InstalledApplicationsViewModel()
	let simulator: Simulator_Legacy

    init(
        simulator: Simulator_Legacy,
        client: Client
    ) {
        self.viewModel = .init(client: client)
        self.simulator = simulator
    }

	var body: some View {
		List {
            ForEach(viewModel.installedApplications, id: \.self) { apps in
                NavigationLink(apps.displayName ?? "N/A") {
					AppSandboxView(
						app: apps,
						simulatorID: simulator.id,
                        client: viewModel.client
					)
                }
            }
		}
		.onAppear {
			viewModel.fetchInstalledApplications(simulator.id)
		}
        .alert(item: $viewModel.failure) {
            Alert(title: Text($0.description))
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
	}
}
