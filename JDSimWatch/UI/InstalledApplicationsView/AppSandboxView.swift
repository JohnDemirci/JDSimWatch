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
    @State private var viewManager: ViewManager

    @State private var showAlert = false
    @State private var success: Success? = nil

	init(environment: ViewManager.Environment) {
        self.viewManager = .init(environment: environment)
    }

    var body: some View {
        List {
            ListRowTapableButton("Application Sandbox Data") {
                viewManager.openApplicationSupport()
            }

            ListRowTapableButton("Open UserDefaults") {
                viewManager.openUserDefaults()
            }

            ListRowTapableButton("Remove UserDefaults") {
                viewManager.removeUserDefaults()
            }

			ListRowTapableButton("Uninstall Application") {
                viewManager.uninstall()
			}
        }
		.onReceive(viewManager.dismissPublisher) {
            success = .message("Successfully uninstalled application", { dismiss() })
		}
        .onReceive(viewManager.alertPublisher) { _ in
            showAlert = true
        }
        .alert(
            viewManager.state.failure?.description ?? "",
            isPresented: $showAlert
        ) {
            Button("ok") {
                viewManager.state.failure = nil
                viewManager.state.showAlert = false
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
        .navigationTitle(viewManager.appName)
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
