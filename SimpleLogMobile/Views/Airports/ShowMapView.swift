//
//  ShowMapView.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/26/25.
//

import SwiftUI
import MapKit

struct ShowMapView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @Binding var airport: Airport?
    
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Map(position: $position)
                    .mapStyle(.hybrid)
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .navigationTitle(airport?.icao ?? "")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            centerMap()
        }
        
    }
    
    private func centerMap() {
        let latitude = airport?.latitude ?? 0
        let longitude = airport?.longitude ?? 0
        
        position = MapCameraPosition.region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: latitude,
                    longitude: longitude
                ),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        )
    }
}
