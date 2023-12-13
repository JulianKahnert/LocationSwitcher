//
//  ContentView.swift
//  Location Switcher
//
//  Created by Julian Kahnert on 13.12.23.
//

import CoreLocation
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    @State private var activeItem: Item?
    @State private var selectedPosition: CLLocationCoordinate2D?

    var body: some View {
        NavigationSplitView {
            sidebarView
                .navigationSplitViewColumnWidth(min: 180, ideal: 200)
                .toolbar {
                    ToolbarItem {
                        Button(action: addItem) {
                            Label("Add Item", systemImage: "plus")
                        }
                        .disabled(selectedPosition == nil)
                    }
                }
        } detail: {
            Group {
                MapView(items: items, activeItem: $activeItem, selectedPosition: $selectedPosition)
            }
        }
    }
    
    private var sidebarView: some View {
        List(selection: $activeItem) {
            ForEach(items) { item in
                Text(item.name)
                    .padding(.horizontal, 3)
                    .padding(.vertical, 2)
                    .clipShape(Capsule())
                    .onTapGesture {
                        selectListItem(item)
                    }
                .contextMenu {
                    Button("Delete...") {
                        delete(item: item)
                    }
                    TextField("Name", text: Binding(get: {
                        item.name
                    }, set: { new, _ in
                        item.name = new
                    }))
                }
                .tag(item)
            }
            .onDelete(perform: deleteItems)
        }
        .listStyle(.sidebar)
    }

    private func addItem() {
        withAnimation {
            guard let selectedPosition else { return }
            let newItem = Item(latitude: selectedPosition.latitude, longitude: selectedPosition.longitude)
            modelContext.insert(newItem)
            self.selectedPosition = nil
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
    private func delete(item: Item) {
        withAnimation {
            modelContext.delete(item)
        }
    }

    private func selectListItem(_ item: Item) {
        try! SimCtl.set(location: item.coordinates)

        activeItem = item
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
