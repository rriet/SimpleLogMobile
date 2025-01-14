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
                Text(aircraft.registration.strUnwrap)
                    .lineLimit(1)
                    .font(.title2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(aircraft.getType.name.strUnwrap)
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
