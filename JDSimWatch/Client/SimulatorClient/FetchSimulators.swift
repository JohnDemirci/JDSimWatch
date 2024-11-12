//
//  FetchSimulators.swift
//  JDSimWatch
//
//  Created by John Demirci on 11/11/24.
//

import Foundation

extension SimulatorClient {
    static func handleFetchShutdownSimulators() -> Result<[Simulator], Error> {
        let result = handleFetchSimulators()
        
        switch result {
        case .success(let dict):
            let values = dict.flatMap(\.value)
            let filtered = values.filter {
                $0.state == "Shutdown"
            }

            return .success(filtered)
        case .failure(let error):
            return .failure(error)
        }
    }
    static func handleFetchBootedSimulators() -> Result<[Simulator], Error> {
        let result = handleFetchSimulators()

        switch result {
        case .success(let dict):
            let values = dict.flatMap(\.value)
            let filtered = values.filter {
                $0.state == "Booted"
            }

            return .success(filtered)
        case .failure(let error):
            return .failure(error)
        }
    }

    static func handleFetchSimulators() -> Result<[String: [Simulator]], Error> {
        switch Shell.shared.execute(.fetchSimulators) {
        case .success(let maybeOutput):
            guard let output = maybeOutput else {
                return .failure(Failure.message("nil output"))
            }

            guard let dataRepresentation = output.data(using: .utf8) else {
                return .failure(Failure.message("unable to encode to data"))
            }

            do {
                let jsonSerialization = try JSONSerialization.jsonObject(with: dataRepresentation, options: []) as? [String: Any]

                guard let jsonSerialization else {
                    return .failure(Failure.message("unable to convert to dictionary"))
                }

                return parse(jsonSerialization)
            } catch {
                return .failure(error)
            }

        case .failure(let error):
            return .failure(error)
        }
    }

    private static func parse(_ json: [String: Any]) -> Result<[String: [Simulator]], Error> {
        var retval: [String: [Simulator]] = [:]
        guard let devicesDict = json["devices"] as? [String: [Any]] else {
            return .failure(Failure.message("unable to decode"))
        }

        devicesDict.forEach { key, value in
            guard !value.isEmpty else { return }

            let simulators = value.compactMap { maybeDict -> Simulator? in
                guard let dict = maybeDict as? [String: Any] else { return nil }
                var simulator = Simulator()

                if let dataPath = dict["dataPath"] as? String {
                    simulator.dataPath = dataPath
                }

                if let logPath = dict["logPath"] as? String {
                    simulator.logPath = logPath
                }

                if let udid = dict["udid"] as? String {
                    simulator.udid = udid
                }

                if let deviceTypeIdentifier = dict["deviceTypeIdentifier"] as? String {
                    simulator.deviceTypeIdentifier = deviceTypeIdentifier
                }

                if let state = dict["state"] as? String {
                    simulator.state = state
                }

                if let dataPathSize = dict["dataPathSize"] as? Int {
                    simulator.dataPathSize = dataPathSize
                }

                if let isAvailable = dict["isAvailable"] as? Bool {
                    simulator.isAvailable = isAvailable
                }

                if let name = dict["name"] as? String {
                    simulator.name = name
                }

                simulator.os = key

                return simulator
            }

            retval[key] = simulators
        }

        return .success(retval)
    }
}
