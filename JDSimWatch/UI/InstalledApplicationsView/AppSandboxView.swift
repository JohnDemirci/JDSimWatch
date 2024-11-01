//
//  AppSandboxView.swift
//  JDSimWatch
//
//  Created by John Demirci on 10/29/24.
//

import SwiftUI

struct AppSandboxView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AppSandboxViewModel

	init(
		app: InstalledApplicationsViewModel.AppInfo,
		simulatorID: String
	) {
		self.viewModel = .init(
			app: app,
			simulatorID: simulatorID
		)
    }

    var body: some View {
        List {
            ListRowTapableButton("Application Sandbox Data") {
                viewModel.openApplicationSupport()
            }

            ListRowTapableButton("Open UserDefaults") {
                viewModel.openUserDefaults()
            }

            ListRowTapableButton("Remove UserDefaults") {
                viewModel.removeUserDefaults()
            }

			ListRowTapableButton("Uninstall Application") {
				viewModel.uninstall()
			}
        }
        .navigationTitle(viewModel.appName)
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

struct ListRowTapableButton: View {
    let title: String
    let action: () -> Void

    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(
            action: {
                action()
            },
            label: {
                Text(title)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
            }
        )
        .buttonStyle(PlainButtonStyle())
    }
}

@Observable
private final class AppSandboxViewModel {
    private let app: InstalledApplicationsViewModel.AppInfo
	private let simulatorID: String

    var failure: Failure?

    var appName: String { app.displayName ?? "" }

	init(
		app: InstalledApplicationsViewModel.AppInfo,
		simulatorID: String
	) {
        self.app = app
		self.simulatorID = simulatorID
    }

    func openApplicationSupport() {
        guard let folderPath = app.dataContainer else {
            failure = .message("No Application Support Folder")
            return
        }
        let expandedPath = NSString(string: folderPath).expandingTildeInPath
        let fileURL = URL(fileURLWithPath: expandedPath)
        if !NSWorkspace.shared.open(fileURL) {
            failure = .message("Could not open Application Support Folder")
        }
    }

    func openUserDefaults() {
        guard let folderPath = app.dataContainer else {
            failure = .message("No User Defaults Folder")
            return
        }

        guard let bundleIdentifier = app.bundleIdentifier else {
            failure = .message("No Bundle Identifier")
            return
        }
        let string = "\(bundleIdentifier).plist"
        let newPath = "\(folderPath)/Library/Preferences/\(string)"
        let fileURL = URL(fileURLWithPath: newPath)

        if !NSWorkspace.shared.open(fileURL) {
            failure = .message("Could not open User Defaults Folder")
        }
    }

	func uninstall() {
		if app.applicationType == "System" {
			failure = .message("cannot remove system apps")
			return
		}

		guard let bundleIdentifier = app.bundleIdentifier else {
			failure = .message("No Bundle Identifier")
			return
		}

		let shell = EnvironmentValues().shell

		let result = shell.execute(.uninstallApp(simulatorID, bundleIdentifier))

		switch result {
		case .success:
			break
		case .failure(let error):
			failure = .message("Could not uninstall app: \(error)")
		}
	}

    func removeUserDefaults() {
        guard let folderPath = app.dataContainer else {
            failure = .message("No User Defaults Folder")
            return
        }
        guard let bundleIdentifier = app.bundleIdentifier else {
            failure = .message("No Bundle Identifier")
            return
        }
        let userDefaultsExtension = "\(bundleIdentifier).plist"
        let newPath = "\(folderPath)/Library/Preferences/\(userDefaultsExtension)"
        let fileURL = URL(fileURLWithPath: newPath)

        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            failure = .message("Could not remove User Defaults File")
        }
    }
}
