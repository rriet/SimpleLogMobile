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
        }
//        VStack(alignment: .leading) {
//            HStack{
//                Text("Registration: ")
//                Text(aircraft.registration.strUnwrap)
//                    .font(.headline)
//                    .fontWeight(.bold)
//                Text(aircraft.isSimulator ? "[Simulator]" : "")
//                    .padding(.leading, 10)
//                    .font(.caption)
//            }
//            .lineLimit(1)
//            .frame(maxWidth: .infinity, alignment: .leading)
//            Text("Type: \(aircraft.aircraftType?.designator ?? "")")
//                .lineLimit(1)
//                .font(.caption)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.leading, 20)
//            Text("MTOW: \(aircraft.mtowString)")
//                .lineLimit(1)
//                .font(.caption)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.leading, 20)
//            
//        }
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
