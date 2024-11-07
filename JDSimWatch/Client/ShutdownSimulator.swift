//
//  ShutdownSimulator.swift
//  JDSimWatch
//
//  Created by John Demirci on 11/7/24.
//

extension Client {
    static func handleShutdownSimulator(id: String) -> Result<Void, Error> {
        switch Shell.shared.execute(.shotdown(id)) {
        case .success:
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }
}
