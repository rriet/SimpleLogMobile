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
    
    var formattedTotalBlockTime: String {
        let hours = flight.timeTotalBlock / 60
        let minutes = flight.timeTotalBlock % 60
        return String(format: "%02d:%02d", hours, minutes)
    }
        
    var body: some View {
        HStack {
            VStack {
                Text(flight.dateStart.toString(format: "dd")) // Day
                    .font(.title)
                    .bold()
                Text(flight.dateStart.toString(format: "MMM")) // Month
                    .font(.title3)
                    .foregroundColor(.gray)
                Text(flight.dateStart.toString(format: "yyyy")) // Year
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            VStack(alignment: .center, spacing: 5) {
                HStack {
                    // Departure & Arrival Airports (ICAO Codes)
                    Text("\(flight.airportDep?.icao ?? "") - \(flight.airportArr?.icao  ?? "")")
                        .font(.title)
                }
                
                // Aircraft Registration
                Text("Aircraft: \(flight.aircraft?.registration  ?? "")")
                    .font(.subheadline)
                
                // Total Block Time formatted as HH:MM
                Text("\(formattedTotalBlockTime)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
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

extension Date {
    func toString(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
