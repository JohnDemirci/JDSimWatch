//
//  RunningProcessesView.swift
//  JDSimWatch
//
//  Created by John Demirci on 8/28/24.
//

import SwiftUI

struct RunningProcessesView: View {
	@Environment(\.dismiss) private var dismiss
	@Environment(\.shell) private var shell

	@State private var viewModel = RunningProcessesViewModel()

	private let simulator: Simulator

	init(simulator: Simulator) {
		self.simulator = simulator
	}

	var body: some View {
		List {
			Section("Processes") {
				ForEach(viewModel.filteredProcesses) { process in
					Text(process.label)
				}
			}
		}
		.searchable(text: $viewModel.filter)
		.onAppear {
			viewModel.fetchRunningProcesses(simulator.id)
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

@Observable
final class RunningProcessesViewModel {
	private var processes: [ProcessInfo] = []
	var filter: String = ""
    var failure: Failure?

	var filteredProcesses: [ProcessInfo] {
		if filter.isEmpty { return processes }

		return processes.filter {
			$0.label.localizedCaseInsensitiveContains(filter)
		}
	}

	func fetchRunningProcesses(_ simulatorID: String) {
		let shell = EnvironmentValues().shell

		switch shell.execute(.activeProcesses(simulatorID)) {
		case .success(let output):
            guard let output else {
                failure = .message("No active processes found.")
                return
            }

			parseOutputData(output)
		case .failure(let error):
            failure = .message("Failed to fetch active processes: \(error)")
			break
		}
	}

	private func parseOutputData(_ inputData: String) {
		let lines = inputData.components(separatedBy: "\n")

		// Parse the lines into an array of ProcessInfo
		var processes = [ProcessInfo]()

		for line in lines.dropFirst() { // Drop the header line
			let components = line.components(separatedBy: "\t")
			if components.count == 3 {
				let processInfo = ProcessInfo(pid: components[0], status: components[1], label: components[2])
				processes.append(processInfo)
			}
		}

		self.processes = processes
	}
}
