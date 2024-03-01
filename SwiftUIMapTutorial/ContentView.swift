//
//  ContentView.swift
//  SwiftUIMapTutorial
//
//  Created by Danielle Lewis on 3/1/24.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @State private var cameraPosition: MapCameraPosition = .region(.userRegion)
    var body: some View {
        Map(position: $cameraPosition) {
//            Marker("My location", systemImage: "basketball", coordinate: .userLocation)
//                .tint(.blue)
            
            // Must request permission for UserAnnotation
//            UserAnnotation()
            
            Annotation("My Location", coordinate: .userLocation) {
                ZStack {
                    Circle()
                        .frame(width: 32, height: 32)
                        .foregroundStyle(.blue.opacity(0.25))
                    
                    Circle()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.white)
                    
                    Circle()
                        .frame(width: 12, height: 12)
                        .foregroundStyle(.blue)
                }
            }
        }
        .mapControls {
            // Adds compass when rotating map
            MapCompass()
            
            // Adds toggle for 2D/3D map
            MapPitchToggle()
            
            // Adds button to snap back to user location. Requires permissions.
            MapUserLocationButton()
        }
    }
}

extension CLLocationCoordinate2D {
    static var userLocation: CLLocationCoordinate2D {
        return .init(latitude: 25.781441, longitude: -80.188332)
    }
}

extension MKCoordinateRegion {
    static var userRegion: MKCoordinateRegion {
        return .init(center: .userLocation,
                    latitudinalMeters: 10000,
                    longitudinalMeters: 10000)
    }
}

#Preview {
    ContentView()
}
