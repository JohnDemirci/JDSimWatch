//
//  SimuWatchApp.swift
//  SimuWatch
//
//  Created by John Demirci on 8/24/24.
//

import Combine
import SwiftUI

@main
struct SimuWatchApp: App {
    @State private var store = SimulatorManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }
    }
}
