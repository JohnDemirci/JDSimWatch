//
//  UninstallApplication.swift
//  JDSimWatch
//
//  Created by John Demirci on 11/7/24.
//

import Foundation

extension SimulatorClient {
    static func handleUninstallApplication(
        _ bundleID: String,
        simulatorID: String
    ) -> Result<Void, Error> {
        switch Shell.shared.execute(.uninstallApp(simulatorID, bundleID)) {
        case .success:
            return .success(())
        case .failure(let error):
            return .failure(Failure.message(error.localizedDescription))
        }
    }
}
