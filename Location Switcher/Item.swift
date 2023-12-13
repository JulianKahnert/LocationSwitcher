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
    var name: String
    var latitude: Double
    var longitude: Double

    @Transient
    var coordinates: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }

    init(name: String? = nil, latitude: Double, longitude: Double) {
        self.name = name ?? "\(String(format: "%.4f", latitude)) | \(String(format: "%.4f", longitude))"
        self.latitude = latitude
        self.longitude = longitude
    }
}

extension Item: Hashable, Equatable {
    
}
