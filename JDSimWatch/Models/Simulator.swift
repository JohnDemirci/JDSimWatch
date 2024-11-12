//
//  Simulator.swift
//  SimuWatch
//
//  Created by John Demirci on 8/25/24.
//

import Combine
import Foundation
import SwiftUI

struct Simulator: Codable, Hashable, Identifiable {
    var dataPath: String?
    var dataPathSize: Int?
    var logPath: String?
    var udid: String?
    var isAvailable: Bool?
    var deviceTypeIdentifier: String?
    var state: String?
    var name: String?
    var os: String?

    init(
        dataPath: String? = nil,
        dataPathSize: Int? = nil,
        logPath: String? = nil,
        udid: String? = nil,
        isAvailable: Bool? = nil,
        deviceTypeIdentifier: String? = nil,
        state: String? = nil,
        name: String? = nil,
        os: String? = nil
    ) {
        self.dataPath = dataPath
        self.dataPathSize = dataPathSize
        self.logPath = logPath
        self.udid = udid
        self.isAvailable = isAvailable
        self.deviceTypeIdentifier = deviceTypeIdentifier
        self.state = state
        self.name = name
        self.os = os
    }

    var id: String { udid ?? UUID().uuidString }
}

struct Simulator_Legacy: Hashable, Identifiable {
    let id: String
    let name: String
}


