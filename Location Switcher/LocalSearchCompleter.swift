//
//  LocalSearchCompleter.swift
//  Example-SwiftUI
//
//  Created by Mikhail Vospennikov on 21.10.2023.
//

import Foundation
import MapKit


struct ExampleClusterAnnotation: Identifiable {
    var id = UUID()
    var coordinate: CLLocationCoordinate2D
    var count: Int
}

// https://stackoverflow.com/questions/68145462/swift-task-continuation-misuse-leaked-its-continuation-for-delegate
class LocalSearchCompleter: NSObject, MKLocalSearchCompleterDelegate {
    override init() {
        completer = MKLocalSearchCompleter()
        super.init()
        completer.delegate = self
//        completer.resultTypes = .address
    }
    
    private let completer: MKLocalSearchCompleter
    private var continuations: [CheckedContinuation<[MKLocalSearchCompletion], Error>] = []
    
    func search(_ searchTerm: String) async throws -> [SidebarView.SearchItem] {
        let completions = try await getCompletions(for: searchTerm)
        print("Found completions", completions.count, completions)
        return try await withThrowingTaskGroup(of: Optional<SidebarView.SearchItem>.self) { group in
            for completion in completions {
                group.addTask{
                    let searchRequest = MKLocalSearch.Request(completion: completion)
                    let search = MKLocalSearch(request: searchRequest)
                    let response = try await search.start()
                    guard let item = response.mapItems.first else { return nil }
                    return SidebarView.SearchItem(name: item.name ?? completion.title, latitude: item.placemark.coordinate.latitude, longitude: item.placemark.coordinate.longitude)
                }
            }
            
            var items = [SidebarView.SearchItem]()
            for try await item in group {
                guard let item else { continue }
                items.append(item)
            }
            
            return items
        }
        
    }
    
    private func getCompletions(for searchTerm: String) async throws -> [MKLocalSearchCompletion] {
        guard !searchTerm.isEmpty else {
            return []
        }

        print("1")
        return try await withCheckedThrowingContinuation { continuation in
            print("2")
            continuations.append(continuation)
            
//            guard !searchTerm.isEmpty else {
//                completerContinuation?.resume(returning: [])
//                completerContinuation = nil
//                 return
//             }
            
            completer.queryFragment = searchTerm
            print("3")
        }
    }
    
    // MARK: - MKLocalSearchCompleterDelegate
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        print("4")
        continuations.forEach { $0.resume(returning: completer.results) }
        continuations.removeAll()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("5")
        continuations.forEach { $0.resume(throwing: error) }
        continuations.removeAll()
    }
}
