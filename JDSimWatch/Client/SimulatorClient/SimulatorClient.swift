//
//  SimulatorAPI.swift
//  JDSimWatch
//
//  Created by John Demirci on 11/5/24.
//

import Foundation

struct SimulatorClient {
    fileprivate var _fetchAllSimulators_Legacy: () -> Result<[InactiveSimulatorParser.OSVersion], Error>
    fileprivate var _fetchBootedSimulators_Legacy: () -> Result<[Simulator_Legacy], Error>
    fileprivate var _shutdownSimulator: (String) -> Result<Void, Error>
    fileprivate var _openSimulator: (String) -> Result<Void, Error>
    fileprivate var _activeProcesses: (String) -> Result<[ProcessInfo], Error>
    fileprivate var _eraseContentAndSettings: (String) -> Result<Void, Error>
    fileprivate var _installedApps: (String) -> Result<[InstalledApplicationsViewModel.AppInfo], Error>
    fileprivate var _uninstallApp: (String, String) -> Result<Void, Error>
    fileprivate var _deleteSimulator: (String) -> Result<Void, Error>

    private init(
        _fetchAllSimulators_Legacy: @escaping () -> Result<[InactiveSimulatorParser.OSVersion], Error>,
        _fetchBootedSimulators_Legacy: @escaping () -> Result<[Simulator_Legacy], Error>,
        _shutdownSimulator: @escaping (String) -> Result<Void, Error>,
        _openSimulator: @escaping (String) -> Result<Void, Error>,
        _activeProcesses: @escaping (String) -> Result<[ProcessInfo], Error>,
        _eraseContentAndSettings: @escaping (String) -> Result<Void, Error>,
        _installedApps: @escaping (String) -> Result<[InstalledApplicationsViewModel.AppInfo], Error>,
        _uninstallApp: @escaping (String, String) -> Result<Void, Error>,
        _deleteSimulator: @escaping (String) -> Result<Void, Error>
    ) {
        self._fetchAllSimulators_Legacy = _fetchAllSimulators_Legacy
        self._fetchBootedSimulators_Legacy = _fetchBootedSimulators_Legacy
        self._shutdownSimulator = _shutdownSimulator
        self._openSimulator = _openSimulator
        self._activeProcesses = _activeProcesses
        self._eraseContentAndSettings = _eraseContentAndSettings
        self._installedApps = _installedApps
        self._uninstallApp = _uninstallApp
        self._deleteSimulator = _deleteSimulator
    }

    func fetchAllSimulators_Legacy() -> Result<[InactiveSimulatorParser.OSVersion], Error> {
        return _fetchAllSimulators_Legacy()
    }

    func fetchBootedSimulators_Legacy() -> Result<[Simulator_Legacy], Error> {
        return _fetchBootedSimulators_Legacy()
    }

    func shutdownSimulator(simulator: String) -> Result<Void, Error> {
        return _shutdownSimulator(simulator)
    }

    func openSimulator(simulator: String) -> Result<Void, Error> {
        return _openSimulator(simulator)
    }

    func activeProcesses(simulator: String) -> Result<[ProcessInfo], Error> {
        return _activeProcesses(simulator)
    }

    func eraseContents(simulator: String) -> Result<Void, Error> {
        return _eraseContentAndSettings(simulator)
    }

    func installedApps(simulator: String) -> Result<[InstalledApplicationsViewModel.AppInfo], Error> {
        return _installedApps(simulator)
    }

    func uninstallApp(_ bundleID: String, at simulatorID: String) -> Result<Void, Error> {
        return _uninstallApp(bundleID, simulatorID)
    }

    func deleteSimulator(simulator: String) -> Result<Void, Error> {
        return _deleteSimulator(simulator)
    }
}

extension SimulatorClient {
    static let live: SimulatorClient = .init(
        _fetchAllSimulators_Legacy: {
            handleFetchAllSimulator_Legacy()
        },
        _fetchBootedSimulators_Legacy: {
            handleFetchBootedSimulators_Legacy()
        },
        _shutdownSimulator: {
            handleShutdownSimulator(id: $0)
        },
        _openSimulator: {
            handleOpenSimulator($0)
        },
        _activeProcesses: {
            handleRunningProcesses($0)
        },
        _eraseContentAndSettings: {
            handleEraseContentAndSettings($0)
        },
        _installedApps: {
            handleInstalledApplications($0)
        },
        _uninstallApp: {
            handleUninstallApplication($0, simulatorID: $1)
        },
        _deleteSimulator: {
            handleDeleteSimulator($0)
        }
    )

    #if DEBUG
    static var testing: SimulatorClient = .init(
        _fetchAllSimulators_Legacy: { fatalError("not implemented") },
        _fetchBootedSimulators_Legacy: { fatalError("not implemented") },
        _shutdownSimulator: { _ in fatalError("not implemented") },
        _openSimulator: { _ in fatalError("not implemented") },
        _activeProcesses: { _ in fatalError("not implemented") },
        _eraseContentAndSettings: { _ in fatalError("not implemented") },
        _installedApps: { _ in fatalError("not implemented")},
        _uninstallApp: { _, _ in fatalError("not implemented") },
        _deleteSimulator: { _ in fatalError("not implemented") }
    )
    #endif
}

extension SimulatorClient {
    @discardableResult
    mutating func mutate(
        _fetchAllSimulators_Legacy: (() -> Result<[InactiveSimulatorParser.OSVersion], Error>)? = nil,
        _fetchBootedSimulators_Legacy:  (() -> Result<[Simulator_Legacy], Error>)? = nil,
        _shutdownSimulator:  ((String) -> Result<Void, Error>)? = nil,
        _openSimulator:  ((String) -> Result<Void, Error>)? = nil,
        _activeProcesses:  ((String) -> Result<[ProcessInfo], Error>)? = nil,
        _eraseContentAndSettings:  ((String) -> Result<Void, Error>)? = nil,
        _installedApps:  ((String) -> Result<[InstalledApplicationsViewModel.AppInfo], Error>)? = nil,
        _uninstallApp:  ((String, String) -> Result<Void, Error>)? = nil,
        _deleteSimulator:  ((String) -> Result<Void, Error>)? = nil
    ) -> Self {
        if let allSimulators = _fetchAllSimulators_Legacy {
            self._fetchAllSimulators_Legacy = allSimulators
        }

        if let bootedSimulators = _fetchBootedSimulators_Legacy {
            self._fetchBootedSimulators_Legacy = bootedSimulators
        }

        if let _shutdownSimulator = _shutdownSimulator {
            self._shutdownSimulator = _shutdownSimulator
        }

        if let _openSimulator = _openSimulator {
            self._openSimulator = _openSimulator
        }

        if let _activeProcesses = _activeProcesses {
            self._activeProcesses = _activeProcesses
        }

        if let _eraseContentAndSettings = _eraseContentAndSettings {
            self._eraseContentAndSettings = _eraseContentAndSettings
        }

        if let _installedApps = _installedApps {
            self._installedApps = _installedApps
        }

        if let _uninstallApp = _uninstallApp {
            self._uninstallApp = _uninstallApp
        }

        if let _deleteSimulator = _deleteSimulator {
            self._deleteSimulator = _deleteSimulator
        }

        return self
    }
}
