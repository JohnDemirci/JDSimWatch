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
                DisclosureGroup(apps.displayName ?? "N/A") {
                    Text(apps.displayName ?? "N/A")

                    Button("Application Contents") {
                        guard let folderPath = apps.dataContainer else { return }
                        let expandedPath = NSString(string: folderPath).expandingTildeInPath
                        let fileURL = URL(fileURLWithPath: expandedPath)
                        NSWorkspace.shared.open(fileURL)
                    }

                    Button("Open UserDefaults") {
                        guard let folderPath = apps.dataContainer else { return }
                        guard let bundleIdentifier = apps.bundleIdentifier else { return }
                        let string = "\(bundleIdentifier).plist"
                        let newPath = "\(folderPath)/Library/Preferences/\(string)"
                        let fileURL = URL(fileURLWithPath: newPath)
                        NSWorkspace.shared.open(fileURL)
                    }

                    Button("Remove User Defaults") {
                        guard let folderPath = apps.dataContainer else { return }
                        guard let bundleIdentifier = apps.bundleIdentifier else { return }
                        let userDefaultsExtension = "\(bundleIdentifier).plist"
                        let newPath = "\(folderPath)/Library/Preferences/\(userDefaultsExtension)"
                        let fileURL = URL(fileURLWithPath: newPath)

                        do {
                            try FileManager.default.removeItem(at: fileURL)
                            print("File successfully removed.")
                        } catch {
                            print("Failed to remove file: \(error.localizedDescription)")
                        }
                    }

                    Text(apps.bundleIdentifier ?? "N/A")
                }
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
