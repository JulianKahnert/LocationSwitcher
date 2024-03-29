//
//  Item.swift
//  Location Switcher
//
//  Created by Julian Kahnert on 13.12.23.
//

import CoreLocation
import SwiftData

@Model
final class Item {
    @Attribute(.unique)
    var id: UUID
    var name: String
    var latitude: Double
    var longitude: Double

    @Transient
    var coordinates: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }

    init(id: UUID = UUID(), name: String? = nil, latitude: Double, longitude: Double) {
        self.id = id
        self.name = name ?? "\(String(format: "%.4f", latitude)) | \(String(format: "%.4f", longitude))"
        self.latitude = latitude
        self.longitude = longitude
    }
}
