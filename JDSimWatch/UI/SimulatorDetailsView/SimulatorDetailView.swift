//
//  SimulatorDetailView.swift
//  SimuWatch
//
//  Created by John Demirci on 8/24/24.
//

import SwiftUI

struct SimulatorDetailView: View {
	@Environment(\.shell) private var shell
    private let simulator: Simulator

    init(simulator: Simulator) {
        self.simulator = simulator
    }

    var body: some View {
		ScrollView {
			Grid {
				GridRow {
					Group {
						ProcessesNavigationLink(simulator: simulator)
						GoToDocumentsView(simulator: simulator)
						EraseContentsView(simulator: simulator)
						InstalledApplicationsButtonView(simulator: simulator)
					}
					.frame(maxWidth: 200, maxHeight: 100, alignment: .center)
				}
			}
		}
		.padding(.top, 20)
		.frame(maxWidth: .infinity)
		.scrollIndicators(.hidden)
		.navigationTitle(simulator.name)
    }
}

private struct GoToDocumentsView: View {
	let simulator: Simulator

	var body: some View {
		Button(
			action: {
				goToDocuments()
			},
			label: {
				VerticalLabeledContentView(systemImage: "folder.fill", text: "Documents")
			}
		)
		.buttonStyle(PlainButtonStyle())
	}
}

private extension GoToDocumentsView {
    func goToDocuments() {
        let folderPath = "~/Library/Developer/CoreSimulator/Devices/\(simulator.id)/data/Documents/"
        let expandedPath = NSString(string: folderPath).expandingTildeInPath
        let fileURL = URL(fileURLWithPath: expandedPath)
        NSWorkspace.shared.open(fileURL)
    }
}

private struct ProcessesNavigationLink: View {
	let simulator: Simulator

	var body: some View {
		NavigationLink(
			destination: {
				RunningProcessesView(simulator: simulator)
			},
			label: {
				VerticalLabeledContentView(
					systemImage: "list.bullet.rectangle",
					text: "Processes"
				)
			}
		)
		.buttonStyle(PlainButtonStyle())
	}
}

private struct EraseContentsView: View {
	@Environment(\.shell) private var shell
	let simulator: Simulator
	var body: some View {
		Button(
			action: {
				eraseSimulator()
			},
			label: {
				VerticalLabeledContentView(
					systemImage: "arrow.clockwise",
					text: "Erase Content"
				)
			}
		)
		.buttonStyle(PlainButtonStyle())
	}
}

extension EraseContentsView {
	func eraseSimulator() {
		shell.eraseContent(uuid: simulator.id)
	}
}

private struct InstalledApplicationsButtonView: View {
	let simulator: Simulator

	var body: some View {
		NavigationLink(
			destination: {
				InstalledApplicationsView(simulator: simulator)
			},
			label: {
				VerticalLabeledContentView(
					systemImage: "app.badge.fill",
					text: "Applications"
				)
			}
		)
		.buttonStyle(PlainButtonStyle())
	}
}
