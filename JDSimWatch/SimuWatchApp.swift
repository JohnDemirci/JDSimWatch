//
//  SimuWatchApp.swift
//  SimuWatch
//
//  Created by John Demirci on 8/24/24.
//

import SwiftUI

@main
struct SimuWatchApp: App {
    @State private var manager: SimulatorManager
    private let simulatorClient: SimulatorClient
    private let folderClient: FolderClient
    private let lifecycleObserver: LifecycleObserver

    init() {
        let lifecycleObserver = LifecycleObserver()

        self.lifecycleObserver = lifecycleObserver
        self.simulatorClient = .live
        self.folderClient = .live
        self.manager = .init(
            lifecycleObserver: lifecycleObserver
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView(
                manager: manager,
                folderClient: folderClient
            )
        }
    }
}
