//
//  AppSandboxView.swift
//  JDSimWatch
//
//  Created by John Demirci on 10/29/24.
//

import Combine
import SwiftUI

struct AppSandboxView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable private var viewModel: AppSandboxViewModel
	@State private var success: Success?
    @State private var showAlert = false

	init(
		app: InstalledApplicationsViewModel.AppInfo,
		simulatorID: String,
        client: Client
	) {
		self.viewModel = .init(
			app: app,
			simulatorID: simulatorID,
            client: client
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
		.onReceive(viewModel.dismissPublisher) {
			success = .message("Successfully uninstalled application", { dismiss() })
		}
        .onReceive(viewModel.alertPublisher) { _ in
            showAlert = true
        }
        .alert(viewModel.failure?.description ?? "", isPresented: $showAlert) {
            Button("ok") {
                viewModel.failure = nil
                showAlert = false
            }
        }
        .alert(item: $success) {
            Alert(
                title: Text($0.description),
                dismissButton: Alert.Button.default(
                    Text("OK"),
                    action: $0.action
                )
            )
        }
        .navigationTitle(viewModel.appName)
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
            action: { action() },
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
final class AppSandboxViewModel {
    private let app: InstalledApplicationsViewModel.AppInfo
	private let simulatorID: String
    private let client: Client

    var failure: Failure? {
        didSet {
            if let failure {
                alertSubject.send(failure)
            }
        }
    }

	private let dismiss = PassthroughSubject<Void, Never>()
    private let alertSubject = PassthroughSubject<Failure, Never>()

	var dismissPublisher: AnyPublisher<Void, Never> { dismiss.eraseToAnyPublisher() }
    var alertPublisher: AnyPublisher<Failure, Never> { alertSubject.eraseToAnyPublisher() }

    var appName: String { app.displayName ?? "" }

	init(
		app: InstalledApplicationsViewModel.AppInfo,
		simulatorID: String,
        client: Client = .live
	) {
        self.app = app
		self.simulatorID = simulatorID
        self.client = client
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

        switch client.uninstallApp(bundleIdentifier, at: simulatorID) {
        case .success:
            dismiss.send(())

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
