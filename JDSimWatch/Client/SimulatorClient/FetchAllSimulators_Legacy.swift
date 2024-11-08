//
//  FetchAllSimulators_Legacy.swift
//  JDSimWatch
//
//  Created by John Demirci on 11/5/24.
//

import Foundation

extension SimulatorClient {
    static func handleFetchAllSimulator_Legacy(
        _ result: Result<String?, Error>
    ) -> Result<[InactiveSimulatorParser.OSVersion], Error> {
        switch result {
        case .success(let maybeOutput):
            guard let output = maybeOutput else {
                return .failure(Failure.message("no output from simulator fetch"))
            }

            return .success(parseDeviceInfo(output))

        case .failure(let error):
            return .failure(error)
        }
    }
}

extension SimulatorClient {
    private static func parseDeviceInfo(_ text: String) -> [InactiveSimulatorParser.OSVersion] {
        var osVersions: [InactiveSimulatorParser.OSVersion] = []
        var currentOS: InactiveSimulatorParser.OSVersion?

        let lines = text.components(separatedBy: .newlines)

        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)

            if trimmedLine.hasPrefix("-- ") && trimmedLine.hasSuffix(" --") {
                // New OS version
                if let currentOS = currentOS {
                    osVersions.append(currentOS)
                }

                let osInfo = trimmedLine.trimmingCharacters(in: CharacterSet(charactersIn: "- "))
                let parts = osInfo.components(separatedBy: " ")
                let name = parts[0]
                let version = parts[1]

                currentOS = InactiveSimulatorParser.OSVersion(name: name, version: version, devices: [])
            } else if !trimmedLine.isEmpty {
                // Device info
                let components = trimmedLine.components(separatedBy: "(")

                guard components.count >= 3 else { continue }

                let name: String
                var uuid: String
                let state: String

                switch components.count {
                case 3:
                    name = components[0].trimmingCharacters(in: .whitespaces)
                    uuid = components[1].trimmingCharacters(in: CharacterSet(charactersIn: "()"))
                    state = components[2].trimmingCharacters(in: CharacterSet(charactersIn: "()"))
                case 4:
                    name = components[0]
                        .trimmingCharacters(in: .whitespaces) + " " +
                    components[1]
                        .trimmingCharacters(in: .whitespaces)

                    uuid = components[2].trimmingCharacters(in: CharacterSet(charactersIn: "()"))
                    state = components[3].trimmingCharacters(in: CharacterSet(charactersIn: "()"))
                case 5:
                    name = components[0]
                        .trimmingCharacters(in: .whitespaces) + " " +
                    components[1]
                        .trimmingCharacters(in: .whitespaces) +
                    components[2]
                        .trimmingCharacters(in: .whitespaces)

                    uuid = components[3].trimmingCharacters(in: CharacterSet(charactersIn: "()"))
                    state = components[4].trimmingCharacters(in: CharacterSet(charactersIn: "()"))
                default:
                    continue
                }

                uuid.removeAll { $0 == ")" }
                uuid.removeAll { $0 == " " }

                let device = InactiveSimulatorParser.Device(name: name, uuid: uuid, state: state)
                currentOS?.devices.append(device)
            }
        }

        // Add the last OS version
        if let currentOS = currentOS {
            osVersions.append(currentOS)
        }

        osVersions.removeAll { version in
            version.devices.isEmpty
        }

        return osVersions
    }
}
