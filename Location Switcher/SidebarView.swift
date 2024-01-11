//
//  SidebarView.swift
//  Location Switcher
//
//  Created by Julian Kahnert on 15.12.23.
//

import SwiftUI

struct SidebarView: View {
    private static let completer = LocalSearchCompleter()
    let items: [Item]
    @Binding var selectedMapItem: SelectableItem?
    
    @Environment(\.modelContext) private var modelContext
    @State private var searchText = ""
    @State private var listItems: [SearchItem] = []
    
    init(items: [Item], selectedMapItem: Binding<SelectableItem?>) {
        self.items = items
        self._selectedMapItem = selectedMapItem
    }
    
    var body: some View {
        List(selection: $selectedMapItem) {
            Section {
                var mergedListItems = listItems.map({ SelectableItem($0) })
                if let selectedMapItem,
                   !(items.map(\.id) + listItems.map(\.id)).contains(selectedMapItem.id) {
                    let _ = mergedListItems.append(selectedMapItem)
                }
                ForEach(mergedListItems) { listItem in
                    Text(listItem.name)
                        .tag(listItem)
                        .onTapGesture {
                            selectListItem(with: listItem.id)
                        }
                }
            }
            
            Section {
                ForEach(items) { listItem in
                    Text(listItem.name)
                        .tag(SelectableItem(listItem))
                        .onTapGesture {
                            selectListItem(with: listItem.id)
                        }
                }
            } header: {
                Text("Saved Locations")
            }
        }
        .listStyle(.sidebar)
        .searchable(text: $searchText, placement: .sidebar)
        .onAppear(perform: performSearch)
        .onChange(of: searchText, performSearch)
        .toolbar {
            ToolbarItem {
                Button {
                    if let selectedMapItem,
                       items.map(\.id).contains(selectedMapItem.id) {
//                    if items.map(\.id).contains(activeItemId ?? UUID()) {
                        deleteItem()
                    } else {
                        addItem()
                    }
                } label: {
                    if let selectedMapItem,
                       items.map(\.id).contains(selectedMapItem.id) {
                        Label("Delete", systemImage: "trash")
                    } else {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        }
    }
    
    private func addItem() {
        
        guard let selectedMapItem,
              !items.map(\.id).contains(selectedMapItem.id) else { return }
        let item = Item(name: selectedMapItem.name, latitude: selectedMapItem.coordinates.latitude, longitude: selectedMapItem.coordinates.longitude)
        
        withAnimation {
            modelContext.insert(item)
            searchText = ""
            listItems = []
            self.selectedMapItem = nil
        }
    }
    
    private func deleteItem() {
        withAnimation {
            guard let selectedMapItem,
                  let item = items.first(where: { $0.id == selectedMapItem.id }) else { return }
            
            modelContext.delete(item)
        }
    }
    
    private func performSearch() {
        Task {
            do {
                guard !searchText.isEmpty else { return }
                print("Perform search")
                let searchItems = try await SidebarView.mapSearch(searchText)
                withAnimation {
                    listItems = searchItems
                }
            } catch {
                print(error)
            }
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

    private func selectListItem(with id: UUID) {
        
        
        var selectedMapItem: SelectableItem?
        
        if let foundDbItem = items.first(where: { $0.id == id }) {
            selectedMapItem = SelectableItem(foundDbItem)
        } else if let foundSearchItem = listItems.first(where: { $0.id == id }) {
            selectedMapItem = SelectableItem(foundSearchItem)
        }

        if let selectedMapItem {
            DispatchQueue.global(qos: .userInitiated).async {
                try! SimCtl.set(location: selectedMapItem.coordinates)
            }
        }
        
        withAnimation {
            self.selectedMapItem = selectedMapItem
        }
    }
}

import MapKit
extension SidebarView {
    static func mapSearch(_ search: String) async throws -> [SearchItem] {
        // TODO: change this to LocalSearchCompleter
//        guard !search.isEmpty else { return [] }
//        
//        print("Start search: \(search)")
//        
//        let results = try await completer.search(search)
//        print("End search: \(search)")
//        
//        return results
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = search
        
        let search = MKLocalSearch(request: searchRequest)
        let response = try await search.start()
               
        let items = response.mapItems.compactMap { item -> SearchItem? in
            guard let name = item.name,
                  let location = item.placemark.location else { return nil }
            
            if let street = item.placemark.thoroughfare,
               let houseNum = item.placemark.subThoroughfare,
               let city = item.placemark.locality {
                
                return SearchItem(name: "\(name), \(street) \(houseNum), \(city)", latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            } else {
                return SearchItem(name: name, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            }
        }
        return Array(items.prefix(5))
    }
    
    struct SearchItem: Hashable, Identifiable {
        let id = UUID()
        let name: String
        let latitude: Double
        let longitude: Double

        var coordinates: CLLocationCoordinate2D {
            .init(latitude: latitude, longitude: longitude)
        }
    }
}

#if DEBUG
#Preview {
    SidebarView(items: [], selectedMapItem: .constant(nil))
}
#endif
