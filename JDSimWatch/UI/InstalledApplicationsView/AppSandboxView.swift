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
        simulatorClient: SimulatorClient,
        folderClient: FolderClient
	) {
		self.viewModel = .init(
			app: app,
			simulatorID: simulatorID,
            simulatorClient: simulatorClient,
            folderClient: folderClient
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
    private let simulatorClient: SimulatorClient
    private let folderClient: FolderClient

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
        simulatorClient: SimulatorClient = .live,
        folderClient: FolderClient = .live
	) {
        self.app = app
		self.simulatorID = simulatorID
        self.simulatorClient = simulatorClient
        self.folderClient = folderClient
    }

    func openApplicationSupport() {
        guard let folderPath = app.dataContainer else {
            failure = .message("No Application Support Folder")
            return
        }

        switch folderClient.openAppSandboxFolder(folderPath) {
        case .success:
            break
        case .failure(let error):
            self.failure = .message(error.localizedDescription)
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

        switch folderClient.openUserDefaults(container: folderPath, bundleID: bundleIdentifier) {
        case .success:
            break
        case .failure(let error):
            self.failure = .message(error.localizedDescription)
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

        switch simulatorClient.uninstallApp(bundleIdentifier, at: simulatorID) {
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

        switch folderClient.removeUserDefaults(container: folderPath, bundleID: bundleIdentifier) {
        case .success:
            break
        case .failure(let error):
            self.failure = .message(error.localizedDescription)
        }
    }
}
