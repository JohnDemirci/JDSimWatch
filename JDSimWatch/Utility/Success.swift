//
//  Success.swift
//  JDSimWatch
//
//  Created by John Demirci on 11/1/24.
//

enum Success: CustomStringConvertible, Identifiable, Hashable {
	case message(String, (() -> Void)?)

    func hash(into hasher: inout Hasher) {
        hasher.combine(description)
    }

    static func == (lhs: Success, rhs: Success) -> Bool {
        lhs.description == rhs.description
    }

	var description: String {
		switch self {
		case .message(let message, _):
			return message
		}
	}

	var action: (() -> Void)? {
		switch self {
		case .message(_, let action):
			return action
		}
	}

	var id: String { description }
}
