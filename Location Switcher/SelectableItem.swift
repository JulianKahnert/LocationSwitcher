//
//  SelectableItem.swift
//  Location Switcher
//
//  Created by Julian Kahnert on 11.01.24.
//

import CoreLocation
import Foundation

struct SelectableItem: Identifiable, Equatable, Hashable {
    let id: UUID
    var name: String {
        didSet {
            self.item?.name = name
        }
    }
    
    var latitude: Double {
        didSet {
            self.item?.latitude = latitude
        }
    }
    
    var longitude: Double {
        didSet {
            self.item?.longitude = longitude
        }
    }
    
    private var item: Item?

    var coordinates: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }
    
    init(id: UUID = UUID(), name: String, coordinates: CLLocationCoordinate2D) {
        self.id = id
        self.name = name
        self.latitude = coordinates.latitude
        self.longitude = coordinates.longitude
    }
    
    init(_ searchItem: SidebarView.SearchItem) {
        self.id = searchItem.id
        self.name = searchItem.name
        self.latitude = searchItem.latitude
        self.longitude = searchItem.longitude
    }
    
    init(_ dbItem: Item) {
        self.id = dbItem.id
        self.name = dbItem.name
        self.latitude = dbItem.latitude
        self.longitude = dbItem.longitude
        self.item = dbItem
    }
}
