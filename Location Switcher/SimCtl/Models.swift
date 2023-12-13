//
//  Models.swift
//  Location Switcher
//
//  Created by Julian Kahnert on 13.12.23.
//

import Foundation

extension SimCtl {
    struct Model: Codable {
        let devices: [String: [Device]]
    }

    // MARK: - Device
    struct Device: Codable {
        let availabilityError: AvailabilityError?
        let dataPath: String
        let dataPathSize: Int
        let logPath, udid: String
        let isAvailable: Bool
        let deviceTypeIdentifier: String
        let state: State
        let name: String
        let logPathSize: Int?
        let lastBootedAt: String?
    }

    enum AvailabilityError: String, Codable {
        case runtimeProfileNotFoundUsingSystemMatchPolicy = "runtime profile not found using \"System\" match policy"
    }

    enum State: String, Codable {
        case booted = "Booted"
        case shutdown = "Shutdown"
    }
}
