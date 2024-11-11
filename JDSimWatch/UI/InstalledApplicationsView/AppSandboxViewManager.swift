//
//  AppSandboxViewManager.swift
//  JDSimWatch
//
//  Created by John Demirci on 11/9/24.
//

import Combine
import SwiftUI

extension AppSandboxView {
    @Observable
    final class ViewManager {
        struct State: Hashable {
            var success: Success?
            var failure: Failure?
            var showAlert = false
        }

        struct Environment {
            let app: InstalledApplicationsViewModel.AppInfo
            let simulatorID: String
            let simulatorClient: SimulatorClient
            let folderClient: FolderClient
            let dismiss = PassthroughSubject<Void, Never>()
            let alertSubject = PassthroughSubject<Failure, Never>()
        }

        var state = State()
        private let environment: Environment

        var appName: String { environment.app.displayName ?? "" }

        var dismissPublisher: AnyPublisher<Void, Never> {
            environment.dismiss.eraseToAnyPublisher()
        }
        var alertPublisher: AnyPublisher<Failure, Never> {
            environment.alertSubject.eraseToAnyPublisher()
        }

        init(environment: Environment) {
            self.environment = environment
        }
    }
}

extension AppSandboxView.ViewManager {
    func openApplicationSupport() {
        guard let folderPath = environment.app.dataContainer else {
            state.failure = .message("No Application Support Folder")
            return
        }

        switch environment.folderClient.openAppSandboxFolder(folderPath) {
        case .success:
            break
        case .failure(let error):
            state.failure = .message(error.localizedDescription)
        }
    }

    func openUserDefaults() {
        guard let folderPath = environment.app.dataContainer else {
            state.failure = .message("No User Defaults Folder")
            return
        }

        guard let bundleIdentifier = environment.app.bundleIdentifier else {
            state.failure = .message("No Bundle Identifier")
            return
        }

        switch environment.folderClient.openUserDefaults(
            container: folderPath,
            bundleID: bundleIdentifier
        ) {
        case .success:
            break
        case .failure(let error):
            state.failure = .message(error.localizedDescription)
        }
    }

    func uninstall() {
        if environment.app.applicationType == "System" {
            state.failure = .message("cannot remove system apps")
            environment.alertSubject.send(state.failure!)
            return
        }

        guard let bundleIdentifier = environment.app.bundleIdentifier else {
            state.failure = .message("No Bundle Identifier")
            environment.alertSubject.send(state.failure!)
            return
        }

        switch environment.simulatorClient.uninstallApp(bundleIdentifier, at: environment.simulatorID) {
        case .success:
            environment.dismiss.send(())

        case .failure(let error):
            state.failure = .message("Could not uninstall app: \(error)")
            environment.alertSubject.send(state.failure!)
        }
    }

    func removeUserDefaults() {
        guard let folderPath = environment.app.dataContainer else {
            state.failure = .message("No User Defaults Folder")
            return
        }
        guard let bundleIdentifier = environment.app.bundleIdentifier else {
            state.failure = .message("No Bundle Identifier")
            return
        }

        switch environment.folderClient.removeUserDefaults(container: folderPath, bundleID: bundleIdentifier) {
        case .success:
            break
        case .failure(let error):
            state.failure = .message(error.localizedDescription)
        }
    }
}
