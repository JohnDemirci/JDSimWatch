//
//  InstalledApplicationViewModel.swift
//  JDSimWatch
//
//  Created by John Demirci on 9/9/24.
//

import Foundation
import SwiftUI

@Observable
final class InstalledApplicationsViewModel {
    var installedApplications: [AppInfo] = []
    var failure: Failure?
    let simulatorClient: SimulatorClient
    let folderClient: FolderClient

    init(
        simulatorClient: SimulatorClient = .live,
        folderClient: FolderClient = .live
    ) {
        self.simulatorClient = simulatorClient
        self.folderClient = folderClient
    }

	func fetchInstalledApplications(_ simulatorID: String) {
        switch simulatorClient.installedApps(simulator: simulatorID) {
        case .success(let infos):
            self.installedApplications = infos

        case .failure(let error):
            failure = .message(error.localizedDescription)
        }
	}
}

extension InstalledApplicationsViewModel {
    struct AppInfo: Hashable {
        var applicationType: String?
        var bundle: String?
        var displayName: String?
        var bundleIdentifier: String?
        var bundleName: String?
        var bundleVersion: String?
        var dataContainer: String?
        var path: String?
    }
}
