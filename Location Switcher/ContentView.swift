//
//  ContentView.swift
//  Location Switcher
//
//  Created by Julian Kahnert on 13.12.23.
//

import CoreLocation
import SwiftUI
import SwiftData

extension Optional where Wrapped == String {
    var _bound: String? {
        get {
            return self
        }
        set {
            self = newValue
        }
    }
    public var bound: String {
        get {
            return _bound ?? ""
        }
        set {
            _bound = newValue.isEmpty ? nil : newValue
        }
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var selectedMapItem: SelectableItem?
    @State private var name: PersonNameComponents? = nil

    var body: some View {
        NavigationSplitView {
            SidebarView(items: items, selectedMapItem: $selectedMapItem)
                .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        } content: {
            MapView(items: items, selectedMapItem: $selectedMapItem)
        } detail: {
            Group {
                if let selectedMapItem {
                    Form {
                        Text("Latitude")
                            .font(.caption)
                            .foregroundStyle(.gray)
                        TextField("", text: Binding(get: {
                            "\(selectedMapItem.coordinates.latitude)"
                        }, set: { value, _ in
                            guard let latitude = Double(value) else { return }
                            self.selectedMapItem?.latitude = latitude
                        }))
                        Text("Longitude")
                            .font(.caption)
                            .foregroundStyle(.gray)
                        TextField("", text: Binding(get: {
                            "\(selectedMapItem.coordinates.longitude)"
                        }, set: { value, _ in
                            guard let longitude = Double(value) else { return }
                            self.selectedMapItem?.longitude = longitude
                        }))

                        Text("Name")
                            .font(.caption)
                            .foregroundStyle(.gray)
                        TextField("", text: Binding<String>(
                            get: {
                                return self.selectedMapItem?.name ?? ""
                        },
                            set: { newString in
                                self.selectedMapItem?.name = newString
                        }))
                    }
                } else {
                    Text("Please select a location first.")
                }
            }
        }
    }


}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
