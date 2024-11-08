//
//  InstalledApplicationsViewModelTests.swift
//  JDSimWatch
//
//  Created by John Demirci on 11/8/24.
//

import Testing
@testable import JDSimWatch

@Suite
struct InstalledApplicationsViewModelTests {
    @Test
    func fetchInstalledApplicationsSuccess() throws {
        let appInfo = InstalledApplicationsViewModel.AppInfo()

        let simulatorClient = SimulatorClient.testing
            .mutate(_installedApps: { _ in
                return .success([appInfo])
            })

        let folderClient = FolderClient.testing

        let viewModel = InstalledApplicationsViewModel(
            simulatorClient: simulatorClient,
            folderClient: folderClient
        )

        viewModel.fetchInstalledApplications("id")

        #expect(viewModel.installedApplications == [appInfo])
    }

    @Test
    func fetchInstalledApplicationFailure() {
        let simulatorClient = SimulatorClient.testing
            .mutate(_installedApps: { _ in
                return .failure(Failure.message("error"))
            })

        let folderClient = FolderClient.testing

        let viewModel = InstalledApplicationsViewModel(
            simulatorClient: simulatorClient,
            folderClient: folderClient
        )

        viewModel.fetchInstalledApplications("id")

        #expect(viewModel.installedApplications.isEmpty)
        #expect(viewModel.failure != nil)
    }
}
