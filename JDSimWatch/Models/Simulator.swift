//
//  Simulator.swift
//  SimuWatch
//
//  Created by John Demirci on 8/25/24.
//

import Combine
import Foundation
import SwiftUI

struct Simulator: Hashable, Identifiable {
    let id: String
    let name: String
}

@Observable
final class SimulatorManager {
    private var observers: [AnyCancellable] = []
    var simulators: [Simulator] = []
    var selectedSimulator: Simulator? = nil

    var failure: Failure?

    init() {
        registerObservers()
    }

    func registerObservers() {
        NSWorkspace
            .shared
            .notificationCenter
            .publisher(for: NSWorkspace.didLaunchApplicationNotification)
            .sink { [weak self] _ in
                self?.fetchSimulators()
            }
            .store(in: &observers)

        NSWorkspace
            .shared
            .notificationCenter
            .publisher(for: NSWorkspace.didActivateApplicationNotification)
            .sink { [weak self] _ in
                self?.fetchSimulators()
            }
            .store(in: &observers)
    }
}

extension SimulatorManager {
    func didSelectSimulator(_ simulator: Simulator) {
        self.selectedSimulator = simulator

        if !self.simulators.contains(simulator) {
            self.simulators.append(simulator)
        }
    }

    func fetchSimulators() {
        let environmentValues = EnvironmentValues()
        let shell = environmentValues.shell

        let result = shell.execute(.fetchBootedSimulators)

        switch result {
        case .success(let maybeOutput):
            guard let output = maybeOutput else {
                self.failure = .message("No simulators found.")
                return
            }

            let list = output
                .split(separator: "\n")
                .map { String($0) }
                .compactMap { parseDeviceInfo($0) }

            self.simulators = list

            if !self.simulators.isEmpty {
                self.selectedSimulator = self.simulators.first!
            } else {
                self.selectedSimulator = nil
            }

        case .failure(let error):
            self.failure = .message(error.localizedDescription)
        }
    }

    func shutdownSimulator(_ simulator: Simulator) {
        let environmentValues = EnvironmentValues()
        let shell = environmentValues.shell

        let result = shell.execute(.shotdown(simulator.id))

        switch result {
        case .success:
            simulators.removeAll { $0 == simulator }
            if selectedSimulator == simulator {
                selectedSimulator = simulators.first
            }
        case .failure(let error):
            self.failure = .message(error.localizedDescription)
        }
    }
}

private extension SimulatorManager {
    func parseDeviceInfo(_ input: String) -> Simulator? {
        let pattern = "^(.+) \\((\\w{8}-\\w{4}-\\w{4}-\\w{4}-\\w{12})\\)"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])

        if let match = regex?.firstMatch(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count)) {
            let nameRange = Range(match.range(at: 1), in: input)!
            let uuidRange = Range(match.range(at: 2), in: input)!

            return Simulator(
                id: String(input[uuidRange]),
                name: String(input[nameRange])
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            )
        } else {
            self.failure = .message("Could not parse device info from \(input)")
            return nil
        }
    }
}
