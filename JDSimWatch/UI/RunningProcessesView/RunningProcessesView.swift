//
//  RunningProcessesView.swift
//  JDSimWatch
//
//  Created by John Demirci on 8/28/24.
//

import SwiftUI

struct RunningProcessesView: View {
	@Environment(\.dismiss) private var dismiss
	@Bindable private var viewModel = RunningProcessesViewModel()
	private let simulator: Simulator_Legacy

	init(
        simulator: Simulator_Legacy,
        simulatorClient: SimulatorClient
    ) {
		self.simulator = simulator
        self.viewModel = .init(simulatorClient: simulatorClient)
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
private final class RunningProcessesViewModel {
	private var processes: [ProcessInfo] = []
	var filter: String = ""
    var failure: Failure?
    let simulatorClient: SimulatorClient

    init(simulatorClient: SimulatorClient = .live) {
        self.simulatorClient = simulatorClient
    }

	var filteredProcesses: [ProcessInfo] {
		if filter.isEmpty { return processes }

		return processes.filter {
			$0.label.localizedCaseInsensitiveContains(filter)
		}
	}

	func fetchRunningProcesses(_ simulatorID: String) {
        switch simulatorClient.activeProcesses(simulator: simulatorID) {
        case .success(let processInfos):
            self.processes = processInfos
            
        case .failure(let error):
            failure = .message(error.localizedDescription)
        }
	}
}
