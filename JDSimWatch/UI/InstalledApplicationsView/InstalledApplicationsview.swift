//
//  InstalledApplicationsview.swift
//  JDSimWatch
//
//  Created by John Demirci on 9/9/24.
//

import Foundation
import SwiftUI

struct InstalledApplicationsView: View {
	@Environment(\.shell) private var shell
    @Environment(\.dismiss) private var dismiss

	@State private var viewModel = InstalledApplicationsViewModel()
	let simulator: Simulator

	var body: some View {
		List {
            ForEach(viewModel.installedApplications, id: \.self) { apps in
                NavigationLink(apps.displayName ?? "N/A") {
                    AppSandboxView(app: apps)
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
