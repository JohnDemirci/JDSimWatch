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
    var body: some Scene {
        WindowGroup {
            ContentView(manager: manager)
        }
    }
}
