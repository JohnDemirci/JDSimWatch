//
//  Failure.swift
//  JDSimWatch
//
//  Created by John Demirci on 10/31/24.
//

enum Failure: Error, CustomStringConvertible, Identifiable, Hashable {
    case message(String)

    var description: String {
        switch self {
        case .message(let message):
            return message
        }
    }

    var id: String { description }

    static func == (lhs: Failure, rhs: Failure) -> Bool {
        lhs.description == rhs.description
    }
}
