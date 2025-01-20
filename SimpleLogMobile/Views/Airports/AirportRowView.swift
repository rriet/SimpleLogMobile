//
//  AirportRowView.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/19/25.
//

import SwiftUI

struct AirportRowView: View {
    
    var airport: Airport
    let onDelete: () -> Void
    let onEdit: () -> Void
    let onTapGesture: () -> Void
    let onToggleLock: () -> Void
    
    var body: some View {
        
        HStack {
            HStack{
                VStack(alignment: .trailing) {
                    Text("ICAO:")
                        .font(.headline)
                    Text("Name:")
                    Text("City:")
                    Text("Country:")
                }
                VStack(alignment: .leading) {
                    Text(airport.icao.strUnwrap)
                        .font(.headline)
                    Text("\(airport.name.strUnwrap) ")
                    Text("\(airport.city.strUnwrap) ")
                    Text("\(airport.country.strUnwrap) ")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack{
                VStack(alignment: .trailing) {
                    Text("IATA:")
                        .font(.headline)
                    Text("Latitude:")
                    Text("Longitude:")
                    Spacer()
                }
                VStack(alignment: .leading) {
                    Text("\(airport.iata.strUnwrap) ")
                        .font(.headline)
                    Text("\(airport.latitude.stringFromLatitude()) ")
                    Text("\(airport.longitude.stringFromLongitude()) ")
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .lineLimit(1)
        .font(.caption)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onTapGesture {onTapGesture()}
        .clipped()
        .listRowBackground(Color.theme.background)
        .swipeActions(allowsFullSwipe: false) {
            SwipeActionsView<Airport>(
                item: airport,
                onDelete: onDelete,
                onEdit: onEdit,
                onToggleLock: onToggleLock
            )}
    }
    
}
