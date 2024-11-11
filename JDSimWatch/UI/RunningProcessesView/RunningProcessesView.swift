//
//  RunningProcessesView.swift
//  JDSimWatch
//
//  Created by John Demirci on 8/28/24.
//

import SwiftUI

struct RunningProcessesView: View {
	@Environment(\.dismiss) private var dismiss
    @State private var viewManager: ViewManager

	init(environment: ViewManager.Environment) {
        self.viewManager = .init(environment: environment)
	}

	var body: some View {
		List {
			Section("Processes") {
                ForEach(viewManager.state.filteredProcesses) { process in
					Text(process.label)
				}
			}
		}
        .searchable(text: $viewManager.state.filter)
		.onAppear {
			viewManager.fetchRunningProcesses()
		}
        .alert(item: $viewManager.state.failure) {
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
		.navigationTitle("Active Processes")
	}
}

struct ProcessInfo: Identifiable, Hashable {
	let pid: String
	let status: String
	let label: String

	var id: String {
		"\(pid)\(status)\(label)"
	}
}
