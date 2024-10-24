//
//  InactiveSimulatorParser.swift
//  SimuWatch
//
//  Created by John Demirci on 8/25/24.
//

import SwiftUI

@Observable
final class InactiveSimulatorParser {
    var osVersionsAndDevices: [OSVersion] = []

    init() {
        self.osVersionsAndDevices = []
    }

    func parseDeviceInfo(_ text: String) {
        var osVersions: [OSVersion] = []
        var currentOS: OSVersion?

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

                currentOS = OSVersion(name: name, version: version, devices: [])
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

                let device = Device(name: name, uuid: uuid, state: state)
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

        self.osVersionsAndDevices = osVersions
    }
}

extension InactiveSimulatorParser {
    struct Device: Hashable, Identifiable {
        let name: String
        let uuid: String
        let state: String

        var id: String {
            "\(name) \(uuid) \(state)"
        }
    }

    struct OSVersion: Hashable, Identifiable {
        let name: String
        let version: String
        var devices: [Device]

        var id: String {
            "\(name),\(version)"
        }
    }
}
