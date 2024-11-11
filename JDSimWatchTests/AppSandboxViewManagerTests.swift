//
//  AppSandboxViewManagerTests.swift
//  JDSimWatch
//
//  Created by John Demirci on 11/10/24.
//

import Combine
import Testing
@testable import JDSimWatch

@Suite
struct AppSandboxViewManagerTests {
    typealias ViewManager = AppSandboxView.ViewManager
}

// MARK: - Test application sandbox folder

extension AppSandboxViewManagerTests  {
    @Test
    func openApplicationSupportWithNilFolderPath() throws {
        let manager = ViewManager(
            environment: .init(
                app: .init(),
                simulatorID: "someID",
                simulatorClient: .testing,
                folderClient: .testing
            )
        )

        manager.openApplicationSupport()

        #expect(manager.state.failure != nil)
    }

    @Test
    func openApplicationSupportWithFailure() throws {
        let folderClient = FolderClient.testing
            .mutate(_openAppSandboxFolder: { _ in
                return .failure(Failure.message("something"))
            })

        let manager = ViewManager(
            environment: .init(
                app: .init(dataContainer: "path"),
                simulatorID: "someID",
                simulatorClient: .testing,
                folderClient: folderClient
            )
        )

        manager.openApplicationSupport()

        #expect(manager.state.failure != nil)
    }

    @Test
    func openApplicationSupportWithSuccess() throws {
        let folderClient = FolderClient.testing
            .mutate(_openAppSandboxFolder: { _ in
                return .success(())
            })

        let manager = ViewManager(
            environment: .init(
                app: .init(dataContainer: "path"),
                simulatorID: "someID",
                simulatorClient: .testing,
                folderClient: folderClient
            )
        )

        manager.openApplicationSupport()

        #expect(manager.state.failure == nil)
    }
}

// MARK: - Test open user defaults

extension AppSandboxViewManagerTests {
    @Test
    func openUserDefaultsWithNilFolderPath() throws {
        let manager = ViewManager(
            environment: .init(
                app: .init(),
                simulatorID: "someID",
                simulatorClient: .testing,
                folderClient: .testing
            )
        )

        manager.openUserDefaults()

        #expect(manager.state.failure != nil)
    }

    @Test
    func openUserDefaultsWithNilBundleIdentifier() throws {
        let manager = ViewManager(
            environment: .init(
                app: .init(dataContainer: "path"),
                simulatorID: "someID",
                simulatorClient: .testing,
                folderClient: .testing
            )
        )

        manager.openUserDefaults()

        #expect(manager.state.failure != nil)
    }

    @Test
    func openUserDefaultsWithFailure() throws {
        let folderClient = FolderClient.testing
            .mutate(_openUserDefaults: { _, _ in
                return .failure(Failure.message("something"))
            })

        let manager = ViewManager(
            environment: .init(
                app: .init(bundleIdentifier: "something", dataContainer: "path"),
                simulatorID: "someID",
                simulatorClient: .testing,
                folderClient: folderClient
            )
        )

        manager.openUserDefaults()

        #expect(manager.state.failure != nil)
    }

    @Test
    func openUserDefaultsWithSuccess() throws {
        let folderClient = FolderClient.testing
            .mutate(_openUserDefaults: { _, _ in
                return .success(())
            })

        let manager = ViewManager(
            environment: .init(
                app: .init(bundleIdentifier: "something", dataContainer: "path"),
                simulatorID: "someID",
                simulatorClient: .testing,
                folderClient: folderClient
            )
        )

        manager.openUserDefaults()

        #expect(manager.state.failure == nil)
    }
}

extension AppSandboxViewManagerTests {
    @Test
    func testUninstallSystemApplicationType() {
        let manager = ViewManager(
            environment: .init(
                app: .init(applicationType: "System"),
                simulatorID: "something",
                simulatorClient: .testing,
                folderClient: .testing
            )
        )

        manager.uninstall()

        #expect(manager.state.failure != nil)
    }

    @Test
    func testUninstallWithNilBundleIdentifier() {
        let manager = ViewManager(
            environment: .init(
                app: .init(),
                simulatorID: "something",
                simulatorClient: .testing,
                folderClient: .testing
            )
        )

        manager.uninstall()

        #expect(manager.state.failure != nil)
    }

    @Test
    func testUninstallApplicationWithFailure() {
        let client = SimulatorClient.testing
            .mutate(_uninstallApp: { _,_ in
                return .failure(Failure.message("something"))
            })

        let manager = ViewManager(
            environment: .init(
                app: .init(bundleIdentifier: "something"),
                simulatorID: "something",
                simulatorClient: client,
                folderClient: .testing
            )
        )

        #expect(manager.state.failure == nil)

        manager.uninstall()

        #expect(manager.state.failure != nil)
    }

    @Test
    func testUninstallApplicationSuccess() async throws {
        let client = SimulatorClient.testing
            .mutate(_uninstallApp: { _,_ in
                return .success(())
            })

        let manager = ViewManager(
            environment: .init(
                app: .init(bundleIdentifier: "something"),
                simulatorID: "something",
                simulatorClient: client,
                folderClient: .testing
            )
        )

        manager.uninstall()
        #expect(manager.state.failure == nil)
    }
}

// MARK: - Remove User Defaults

extension AppSandboxViewManagerTests {
    @Test
    func removeUserDefaultsWithNilFolderPath() {
        let manager = ViewManager(
            environment: .init(
                app: .init(),
                simulatorID: "something",
                simulatorClient: .testing,
                folderClient: .testing
            )
        )

        manager.removeUserDefaults()

        #expect(manager.state.failure != nil)
    }

    @Test
    func removeUserDefaultsWithNilBundleIdentifier() {
        let manager = ViewManager(
            environment: .init(
                app: .init(dataContainer: "something"),
                simulatorID: "something",
                simulatorClient: .testing,
                folderClient: .testing
            )
        )

        manager.removeUserDefaults()

        #expect(manager.state.failure != nil)
    }

    @Test
    func removeUserDefaultsFailure() {
        let client = FolderClient.testing
            .mutate(_removeUserDefaults: { _, _ in
                return .failure(Failure.message("something"))
            })

        let manager = ViewManager(
            environment: .init(
                app: .init(bundleIdentifier: "id", dataContainer: "something"),
                simulatorID: "something",
                simulatorClient: .testing,
                folderClient: client
            )
        )

        manager.removeUserDefaults()

        #expect(manager.state.failure != nil)
    }

    @Test
    func removeUserDefaultsSuccess() {
        let client = FolderClient.testing
            .mutate(_removeUserDefaults: { _, _ in
                return .success(())
            })

        let manager = ViewManager(
            environment: .init(
                app: .init(bundleIdentifier: "id", dataContainer: "something"),
                simulatorID: "something",
                simulatorClient: .testing,
                folderClient: client
            )
        )

        manager.removeUserDefaults()

        #expect(manager.state.failure == nil)
    }
}
