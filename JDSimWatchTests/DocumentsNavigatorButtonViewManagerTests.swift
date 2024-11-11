//
//  DocumentsNavigatorButtonViewManagerTests.swift
//  JDSimWatch
//
//  Created by John Demirci on 11/10/24.
//

import Testing
@testable import JDSimWatch

@Suite
struct DocumentsNavigatorButtonViewManagerTests {
    private typealias ViewManager = SimulatorDetailView.DocumentsNavigatorButtonView.ViewManager

    @Test
    func didSelectDocument() {
        let simulator = Simulator_Legacy(id: "one", name: "one")
        let client = FolderClient.testing
            .mutate(_openSimulatorDocuments: { _ in
                return .success(())
            })

        let viewManager = ViewManager(
            environment: .init(
                simulator: simulator,
                folderClient: client
            )
        )

        viewManager.didSelectDocuments()

        #expect(viewManager.failure == nil)
    }

    @Test
    func didSelectDocumentsFails() {
        let simulator = Simulator_Legacy(id: "one", name: "one")
        let client = FolderClient.testing
            .mutate(_openSimulatorDocuments: { _ in
                return .failure(Failure.message("something"))
            })

        let viewManager = ViewManager(
            environment: .init(
                simulator: simulator,
                folderClient: client
            )
        )

        viewManager.didSelectDocuments()

        #expect(viewManager.failure != nil)
    }
}
