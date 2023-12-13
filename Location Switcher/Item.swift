//
//  Item.swift
//  Location Switcher
//
//  Created by Julian Kahnert on 13.12.23.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
