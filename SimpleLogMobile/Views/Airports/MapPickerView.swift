//
//  CoordinatePickerView.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/19/25.
//

import SwiftUI
import MapKit

struct MapPickerView: View {
    
    // Environment property to dismiss the current view
    @Environment(\.dismiss) var dismiss
    
    @State private var position = MapCameraPosition.region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 1000.0, longitudeDelta: 1000.0)
    ))
    
    @State private var selectedCoordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    @Binding var latitude: Double
    @Binding var longitude: Double
    
    var body: some View {
        VStack {
            Text("Tap on the map to select location")
            // Map view
            MapReader { proxy in
                Map(position: $position)
                    .mapStyle(.hybrid)
                    .onTapGesture { position in
                        if let coordinate = proxy.convert(position, from: .local) {
                            selectedCoordinates = coordinate
                            latitude = coordinate.latitude
                            longitude = coordinate.longitude
                        }
                    }
            }
//            .frame(height: 600)
            
            Spacer()
            
            Button(action: {
                dismiss()
            }) {
                VStack {
                    Text("Selected This Location:")
                        .font(.headline)
                    HStack {
                        VStack(alignment: .trailing) {
                            Text("Latitude:")
                            Text("Longitude:")
                        }
                        VStack(alignment: .leading) {
                            Text("\(latitude.stringFromLatitude())")
                            Text("\(longitude.stringFromLongitude())")
                        }
                    }
                }
                .font(.caption)
                .padding()
            }
            .foregroundColor(.white)
            .background(
                Color.blue
                .cornerRadius(10)
                .shadow(radius: 10))
        }
        .padding()
        .onAppear {
            centerMap()
        }
    }
    
    private func centerMap() {
        if !latitude.isZero && !longitude.isZero {
            position = MapCameraPosition.region(
                MKCoordinateRegion(
                    center: CLLocationCoordinate2D(
                        latitude: latitude,
                        longitude: longitude
                    ),
                    span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
                )
            )
        }
    }
}

