//
//  Process.swift
//  Location Switcher
//
//  Created by Julian Kahnert on 13.12.23.
//

import Foundation

// From: https://github.com/twostraws/ControlRoom/
extension Process {
    @discardableResult static func execute(_ command: String, arguments: [String]) -> Data? {
        let task = Process()
        task.launchPath = command
        task.arguments = arguments

        let pipe = Pipe()
        task.standardOutput = pipe

        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return data
        } catch {
            return nil
        }
    }
}
