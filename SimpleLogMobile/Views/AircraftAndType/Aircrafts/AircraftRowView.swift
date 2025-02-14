//
//  AircraftRowView.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/11/25.
//

import SwiftUI

struct AircraftRowView: View {
    
    var aircraft: Aircraft
    let onDelete: () -> Void
    let onEdit: () -> Void
    let onTapGesture: () -> Void
    let onToggleLock: () -> Void
    let onToggleFavorite: () -> Void
    
    var body: some View {
        HStack{
            VStack (alignment: .trailing) {
                Text("Registration:")
                Text("Type:")
                    .font(.caption)
                Text("MTOW:")
                    .font(.caption)
            }
            VStack (alignment: .leading) {
                HStack {
                    Text(aircraft.registration.strUnwrap)
                        .lineLimit(1)
                        .font(.headline)
                        .fontWeight(.bold)
                    Text(aircraft.isSimulator ? "[Sim]" : "")
                        .padding(.leading, 10)
                }
                Text(aircraft.aircraftType?.designator ?? "")
                    .lineLimit(1)
                    .font(.caption)
                Text("\(aircraft.mtowString)")
                    .lineLimit(1)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Button(action: onToggleFavorite) {
                Image(systemName: aircraft.isFavorite ? "star.fill" : "star")
                    .foregroundColor(aircraft.isFavorite ? .yellow : .gray)
                    .padding(.trailing, 8)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .frame(maxWidth: .infinity)
        .clipped()
        .listRowBackground(Color.theme.background)
        .swipeActions(allowsFullSwipe: false) {
            SwipeActionsView<Aircraft>(
                item: aircraft,
                onDelete: onDelete,
                onEdit: onEdit,
                onToggleLock: onToggleLock
            )
        }
        .onTapGesture {onTapGesture()}
    }
}
