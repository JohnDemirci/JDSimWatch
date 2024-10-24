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
	@State private var viewModel = InstalledApplicationsViewModel()
	let simulator: Simulator

	var body: some View {
		List {
			ForEach(Array(viewModel.installedApplications.keys), id: \.self) {
				Text($0)
			}
		}
		.onAppear {
			viewModel.fetchInstalledApplications(simulator.id)
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
