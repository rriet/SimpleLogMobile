//
//  FlightRowView.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/26/25.
//

import SwiftUI

struct FlightRowView: View {
    
    var flight: Flight
    let onDelete: () -> Void
    let onEdit: () -> Void
    let onTapGesture: () -> Void
    let onToggleLock: () -> Void
    let onImageTapGesture: () -> Void
    
    var body: some View {
        HStack{
            VStack(alignment: .leading) {
                Text(flight.dateStart.description)
                    .lineLimit(1)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .onTapGesture {onTapGesture()}
            
        }
        .frame(maxWidth: .infinity, minHeight: 70)
        .clipped()
        .listRowBackground(Color.theme.background)
        .swipeActions(allowsFullSwipe: false) {
            SwipeActionsView<Flight>(
                item: flight,
                onDelete: onDelete,
                onEdit: onEdit,
                onToggleLock: onToggleLock
            )
        }
    }
    
}
