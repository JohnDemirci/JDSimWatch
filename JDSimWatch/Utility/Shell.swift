//
//  Shell.swift
//  SimuWatch
//
//  Created by John Demirci on 8/25/24.
//

import SwiftUI

struct Shell {
    func execute(_ command: Shell.Command) -> Result<String?, Error> {
        switch command {
        case .fetchBootedSimulators,
             .shotdown,
			 .uninstallApp,
             .activeProcesses,
             .installedApps,
             .fetchAllSimulators:           basicExecute(command)

        case .eraseContents(let uuid):      eraseContent(uuid: uuid)

        case .openSimulator(let uuid):      openSimulator(uuid: uuid)
        }
    }

    private func basicExecute(_ command: Shell.Command) -> Result<String?, Error> {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: command.path)
        process.arguments = command.arguments

        let pipe = Pipe()
        process.standardOutput = pipe

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            return .failure(error)
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()

        guard let stringOutput = String(data: data, encoding: .utf8) else {
            return .failure(Failure.decoding)
        }

        return .success(stringOutput)
    }

    private func eraseContent(uuid: String) -> Result<String?, Error> {
		let shutdownProcess = Process()
		let eraseProcess = Process()

		let shutDownCommand = Shell.Command.shotdown(uuid)
		shutdownProcess.executableURL = URL(fileURLWithPath: shutDownCommand.path)
		shutdownProcess.arguments = shutDownCommand.arguments

		let eraseCommand = Shell.Command.eraseContents(uuid)
		eraseProcess.executableURL = URL(fileURLWithPath: eraseCommand.path)
		eraseProcess.arguments = eraseCommand.arguments

		do {
			try shutdownProcess.run()
			shutdownProcess.waitUntilExit()

			try eraseProcess.run()
			eraseProcess.waitUntilExit()

			_ = openSimulator(uuid: uuid)
            return .success(nil)
		} catch {
            return .failure(error)
		}
	}

	@discardableResult
    private func openSimulator(uuid: String) -> Result<String?, Error> {
        let bootProcess = Process()
        bootProcess.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        bootProcess.arguments = ["simctl", "boot", uuid]

        let openProcess = Process()
        openProcess.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        openProcess.arguments = ["-a", "Simulator", "--args", "-CurrentDeviceUDID", uuid]

        do {
            try bootProcess.run()
            bootProcess.waitUntilExit()

            try openProcess.run()
            openProcess.waitUntilExit()

            return .success(nil)
        } catch {
            print("Failed to open simulator: \(error)")
            return .failure(error)
        }
    }
}

extension Shell {
    enum Failure: Error {
        case decoding
    }
}

extension Shell {
    enum Command {
        case fetchBootedSimulators
        case fetchAllSimulators
        case shotdown(String)
        case openSimulator(String)
		case activeProcesses(String)
		case eraseContents(String) // do not exclusively call this when executing command use the helper function
		case installedApps(String)
		case uninstallApp(String, String)

		var path: String {
			switch self {
	 		case .fetchBootedSimulators:
				"/bin/bash"
			case .fetchAllSimulators:
				"/bin/bash"
			case .shotdown:
				"/usr/bin/xcrun"
			case .activeProcesses:
				"/bin/bash"
			case .eraseContents:
				"/usr/bin/xcrun"
			case .installedApps:
				"/usr/bin/xcrun"
            case .openSimulator:
                ""
			case .uninstallApp:
				"/usr/bin/xcrun"
			}
		}

        var arguments: [String] {
            switch self {
			case .installedApps(let id):
				["simctl", "listapps", id]

			case .eraseContents(let id):
				["simctl", "erase", id]

            case .fetchBootedSimulators:
                ["-c", "xcrun simctl list devices | grep Booted"]

            case .fetchAllSimulators:
                ["-c", "xcrun simctl list devices"]

            case .shotdown(let uuid):
                ["simctl", "shutdown", uuid]

			case .activeProcesses(let uuid):
				["-c", "xcrun simctl spawn \(uuid) launchctl list"]

            case .openSimulator:
                []

			case .uninstallApp(let simulatorUUID, let bundleID):
				["simctl", "uninstall", simulatorUUID, bundleID]
            }
        }
    }
}

private struct ShellEnvironmentKey: EnvironmentKey {
    static let defaultValue: Shell = .init()
}

extension EnvironmentValues {
    var shell: Shell {
        get { self[ShellEnvironmentKey.self] }
    }
}
