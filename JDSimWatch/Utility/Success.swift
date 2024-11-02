//
//  Success.swift
//  JDSimWatch
//
//  Created by John Demirci on 11/1/24.
//

enum Success: CustomStringConvertible, Identifiable {
	case message(String, (() -> Void)?)

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
