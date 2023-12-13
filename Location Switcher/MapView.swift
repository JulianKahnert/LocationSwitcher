//
//  MapView.swift
//  Location Switcher
//
//  Created by Julian Kahnert on 13.12.23.
//

import MapKit
import SwiftUI

struct MapView: View {
    var items: [Item]
    @Binding var activeItem: Item?

    @Binding var selectedPosition: CLLocationCoordinate2D?
    @State private var position: MapCameraPosition = .userLocation(
        fallback: .camera(
            MapCamera(centerCoordinate: .init(latitude: 53.169929117557196, longitude: 8.212793159727328), distance: 0)
        )
    )

    var body: some View {
        MapReader { proxy in
            Map(position: $position) {
                // show user location
                UserAnnotation()

                // tapped location
                if let selectedPosition {
                    Annotation("Selection", coordinate: selectedPosition) {
                        Image(systemName: "mappin")
                            .foregroundStyle(.black)
                            .padding(6)
                            .background(.red)
                            .clipShape(Circle())
                    }
                }

                ForEach(items) { item in
                    Annotation(item.name, coordinate: item.coordinates) {
                        Image(systemName: "mappin")
                            .foregroundStyle(.black)
                            .padding(6)
                            .background(item == activeItem ? .yellow : .gray)
                            .clipShape(Circle())
                    }
                }
            }
            .mapStyle(
                .hybrid(
                    elevation: .flat,
                    pointsOfInterest: .including([.airport]),
                    showsTraffic: false
                )
            )
            .mapControls {
                MapScaleView()
                MapCompass()
                MapUserLocationButton()
            }
            .onTapGesture(perform: { screenCoord in
                let pinLocation = proxy.convert(screenCoord, from: .local)
                selectedPosition = pinLocation
            })
            .onChange(of: activeItem) { oldValue, newValue in
                guard let newValue else { return }
                withAnimation {
                    // TODO: ideally the zoomlevel would not change
                    position = .rect(MKMapRect(origin: .init(newValue.coordinates), size: MKMapSize(width: 1, height: 1)))
//                    position = .camera(proxy.camera(framing: MKMapItem(placemark: .init(coordinate: newValue.coordinates)), allowPitch: false))
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    MapView(items: [], activeItem: .constant(nil), selectedPosition: .constant(nil))
}
#endif
