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
        Section(){
            VStack(alignment: .leading) {
                //                VStack{
                //                    ForEach (
                //                        aircraftType.aircrafts?.allObjects as? [Aircraft] ?? [],
                //                        id: \.self
                //                    ) { acft in
                //                        Text(acft.registration.strUnwrap)
                //                    }
                //                }
                Text(aircraft.registration.strUnwrap)
                    .lineLimit(1)
                    .font(.title2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(aircraft.aircraftType?.name ?? "")
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
}
