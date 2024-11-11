//
//  FetchBootedSimulators_Legacy.swift
//  JDSimWatch
//
//  Created by John Demirci on 11/5/24.
//

import Foundation

extension SimulatorClient {
    static func handleFetchBootedSimulators_Legacy() -> Result<[Simulator_Legacy], Error> {
        switch Shell.shared.execute(.fetchBootedSimulators) {
        case .success(let maybeOutput):
            guard let output = maybeOutput else {
                return .failure(Failure.message("no output from fetchBootedSimulators"))
            }

            let list = output
                .split(separator: "\n")
                .map { String($0) }
                .compactMap { parseDeviceInfo($0) }

            return .success(list)

        case .failure(let error):
            return .failure(error)
        }
    }
}

extension SimulatorClient {
    private static func parseDeviceInfo(_ input: String) -> Simulator_Legacy? {
        let pattern = "^(.+) \\((\\w{8}-\\w{4}-\\w{4}-\\w{4}-\\w{12})\\)"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])

        if let match = regex?.firstMatch(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count)) {
            let nameRange = Range(match.range(at: 1), in: input)!
            let uuidRange = Range(match.range(at: 2), in: input)!

            return Simulator_Legacy(
                id: String(input[uuidRange]),
                name: String(input[nameRange])
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            )
        } else {
            return nil
        }
    }
}
