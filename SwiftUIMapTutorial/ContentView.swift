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
    @State private var searchText = ""
    @State private var results = [MKMapItem]()
    @State private var mapSelection: MKMapItem?
    @State private var showDetails = false
    @State private var getDirections = false
    @State private var routeDisplaying = false
    @State private var route: MKRoute?
    @State private var routeDestination: MKMapItem?
    
    var body: some View {
        Map(position: $cameraPosition, selection: $mapSelection) {
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
            
            ForEach(results, id: \.self) { item in
                let placemark = item.placemark
                Marker(placemark.name ?? "", coordinate: placemark.coordinate)
            }
            
            if let route {
                MapPolyline(route.polyline)
                    .stroke(.blue, lineWidth: 6)
            }
        }
        .overlay(alignment: .top) {
            TextField("Search for a location...", text: $searchText)
                .font(.subheadline)
                .padding(12)
                .background(.white)
                .padding()
                .shadow(radius: 10)
        }
        .onSubmit(of: .text) {
            Task {
                await searchPlaces()
            }
        }
        .onChange(of: mapSelection) {
            // Only show details if an annotation is selected
            showDetails = mapSelection != nil
        }
        .onChange(of: getDirections) {
            if getDirections {
                fetchRoute()
            }
        }
        .sheet(isPresented: $showDetails) {
            LocationDetailsView(mapSelection: $mapSelection,
                                show: $showDetails,
                                getDirections: $getDirections)
                .presentationDetents([.height(340)])
            // Allows you to still interact with the map even though the sheet is being presented
                .presentationBackgroundInteraction(.enabled(upThrough: .height(340)))
                .presentationCornerRadius(12)
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

extension ContentView {
    func searchPlaces() async {
        // Generate local search request
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = .userRegion
        
        let results = try? await MKLocalSearch(request: request).start()
        self.results = results?.mapItems ?? []
    }
    
    func fetchRoute() {
        if let mapSelection {
            // Generate directions request
            let request = MKDirections.Request()
            // Starting location
            request.source = MKMapItem(placemark: .init(coordinate: .userLocation))
            // Destination
            request.destination = mapSelection
            
            Task {
                let result = try? await MKDirections(request: request).calculate()
                route = result?.routes.first
                routeDestination = mapSelection
                
                withAnimation(.snappy) {
                    routeDisplaying = true
                    showDetails = false
                    
                    // Update camera position to be equal to the polyline's boundingMapRect
                    // boundingMapRect is the smallest rectangle that completely encompasses the overlay
                    if let rect = route?.polyline.boundingMapRect, routeDisplaying {
                        cameraPosition = .rect(rect)
                    }
                }
            }
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
