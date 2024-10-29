//
//  AppSandboxView.swift
//  JDSimWatch
//
//  Created by John Demirci on 10/29/24.
//

import SwiftUI

struct AppSandboxView: View {
    @Environment(\.dismiss) private var dismiss
    private let viewModel: AppSandboxViewModel

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

private final class AppSandboxViewModel {
    private let app: InstalledApplicationsViewModel.AppInfo

    var appName: String { app.displayName ?? "" }

    init(app: InstalledApplicationsViewModel.AppInfo) {
        self.app = app
    }

    func openApplicationSupport() {
        guard let folderPath = app.dataContainer else { return }
        let expandedPath = NSString(string: folderPath).expandingTildeInPath
        let fileURL = URL(fileURLWithPath: expandedPath)
        NSWorkspace.shared.open(fileURL)
    }

    func openUserDefaults() {
        guard let folderPath = app.dataContainer else { return }
        guard let bundleIdentifier = app.bundleIdentifier else { return }
        let string = "\(bundleIdentifier).plist"
        let newPath = "\(folderPath)/Library/Preferences/\(string)"
        let fileURL = URL(fileURLWithPath: newPath)
        NSWorkspace.shared.open(fileURL)
    }

    func removeUserDefaults() {
        guard let folderPath = app.dataContainer else { return }
        guard let bundleIdentifier = app.bundleIdentifier else { return }
        let userDefaultsExtension = "\(bundleIdentifier).plist"
        let newPath = "\(folderPath)/Library/Preferences/\(userDefaultsExtension)"
        let fileURL = URL(fileURLWithPath: newPath)

        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            // TODO: - handle error
            print("Failed to remove file: \(error.localizedDescription)")
        }
    }
}
