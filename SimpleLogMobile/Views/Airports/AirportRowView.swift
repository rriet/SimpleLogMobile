//
//  AirportRowView.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/19/25.
//

import SwiftUI

struct AirportRowView: View {
    
    @Binding var airport: Airport
    let onDelete: () -> Void
    let onEdit: () -> Void
    let onTapGesture: () -> Void
    let onToggleLock: () -> Void
    let onToggleFavorite: () -> Void
    
    var body: some View {
        HStack{
            Grid(alignment: .topLeading,
                 horizontalSpacing: 1,
                 verticalSpacing: 3) {
                GridRow {
                    Text("ICAO:")
                        .gridColumnAlignment(.trailing)
                    Text(airport.icao.strUnwrap)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("IATA:")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .gridColumnAlignment(.trailing)
                    Text("\(airport.iata.strUnwrap) ")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .font(.headline)
                GridRow {
                    Text("Name:")
                    Text("\(airport.name.strUnwrap) ")
                        .gridCellColumns(3)
                }
                GridRow {
                    Text("City:")
                    Text(airport.city.strUnwrap)
                        .gridCellColumns(3)
                }
                GridRow {
                    Text("Country:")
                    Text(airport.country.strUnwrap)
                        .gridCellColumns(3)
                }
            }
                 .lineLimit(1)
                 .minimumScaleFactor(0.8)
                 .clipped()
                 .font(.caption)
                 .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                 .contentShape(Rectangle())
                 .onTapGesture {onTapGesture()}

            Button(action: onToggleFavorite) {
                Image(systemName: airport.isFavorite ? "star.fill" : "star")
                    .foregroundColor(airport.isFavorite ? .yellow : .gray)
                    .padding(.trailing, 8)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
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
