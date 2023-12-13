//
//  SimCtl.swift
//  Location Switcher
//
//  Created by Julian Kahnert on 13.12.23.
//

import CoreLocation
import Foundation

enum SimCtl {
    static func set(location: CLLocationCoordinate2D) throws {
        print("Setting location \(location)")
        let udids = try getBootedSimulatorUDIDs()
        for udid in udids {
            // xcrun simctl location 88855E5F-3965-4F9E-8520-27C983E1FB38 set 53.12477,8.13981
            Process.execute("/usr/bin/xcrun", arguments: ["simctl", "location", udid.uuidString, "set", "\(location.latitude),\(location.longitude)"])
        }
        //        let simulators: [String] = []
        //        let userInfo: [AnyHashable: Any] = [
        //             "simulateLocationLatitude": item.latitude,
        //             "simulateLocationLongitude": item.longitude,
        //             "simulateLocationDevices": simulators,
        //         ]
        //
        //        let notification = Notification(name: Notification.Name(rawValue: "com.apple.iphonesimulator.simulateLocation"), object: nil,
        //                                        userInfo: userInfo)
        //
        //        DistributedNotificationCenter.default().post(notification)
    }

    private static func getBootedSimulatorUDIDs() throws -> [UUID] {
        guard let data = Process.execute("/usr/bin/xcrun", arguments: ["simctl", "list", "-j", "devices"]) else { return [] }
        let response = try JSONDecoder().decode(Model.self, from: data)
        return response.devices.flatMap(\.value).filter({$0.state == .booted}).compactMap { UUID(uuidString: $0.udid) }
    }
}
