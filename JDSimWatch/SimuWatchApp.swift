//
//  SimuWatchApp.swift
//  SimuWatch
//
//  Created by John Demirci on 8/24/24.
//

import SwiftUI

@main
struct SimuWatchApp: App {
    @State private var manager = SimulatorManager()
    private let simulatorClient: SimulatorClient = .live
    private let folderClient: FolderClient = .live

    var body: some Scene {
        WindowGroup {
            ContentView(
                manager: manager,
                folderClient: folderClient
            )
        }
    }
}
