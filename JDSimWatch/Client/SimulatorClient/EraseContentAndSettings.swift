//
//  EraseContentAndSettings.swift
//  JDSimWatch
//
//  Created by John Demirci on 11/7/24.
//

import Foundation

extension SimulatorClient {
    static func handleEraseContentAndSettings(_ id: String) -> Result<Void, Error> {
        switch Shell.shared.execute(.eraseContents(id)) {
        case .success:
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }
}
