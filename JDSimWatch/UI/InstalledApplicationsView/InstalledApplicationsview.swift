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
                Text(apps.displayName ?? "")
            }
		}
		.onAppear {
			viewModel.fetchInstalledApplications(simulator.id)
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

private extension InstalledApplicationsView {
	func fetchInstalledApps() {
		let result = shell.execute(command: .installedApps(simulator.id))

		switch result {
		case .success(let output):
			dump(output)
		case .failure(let error):
			dump(error)
		}
	}
}
