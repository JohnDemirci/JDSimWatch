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

    init(app: InstalledApplicationsViewModel.AppInfo) {
        self.viewModel = .init(app: app)
    }

    var body: some View {
        List {
            ListRowTapableButton("Application Support") {
                viewModel.openApplicationSupport()
            }

            ListRowTapableButton("Open UserDefaults") {
                viewModel.openUserDefaults()
            }

            ListRowTapableButton("Remove UserDefaults") {
                viewModel.removeUserDefaults()
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

    var failure: Failure?

    var appName: String { app.displayName ?? "" }

    init(app: InstalledApplicationsViewModel.AppInfo) {
        self.app = app
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
