//
//  TypeRowView.swift
//  SimpleLog
//
//  Created by Ricardo Brito Riet Correa on 1/11/25.
//

import SwiftUI

struct TypeRowView: View {
    
    var aircraftType: AircraftType
    let onDelete: () -> Void
    let onEdit: () -> Void
    let onTapGesture: () -> Void
    let onToggleLock: () -> Void
    
    var body: some View {
        Section(){
            HStack(alignment: .top) {
//                VStack{
//                    ForEach (
//                        aircraftType.aircrafts?.allObjects as? [Aircraft] ?? [],
//                        id: \.self
//                    ) { acft in
//                        Text(acft.registration.strUnwrap)
//                    }
//                }
                Text(aircraftType.name.strUnwrap)
                    .lineLimit(1)
                    .font(.title2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                VStack(alignment: .leading) {
                    Text("Maker: \(aircraftType.maker.strUnwrap)")
                        .lineLimit(1)
                    Text("Engine: \(aircraftType.engineType.strUnwrap)")
                    Text("Category: \(aircraftType.categoryString.strUnwrap)")
                    Text("MTOW: \(aircraftType.mtow)")
                }
                .font(.subheadline)
                .frame(maxWidth: .infinity)
                VStack(alignment: .leading) {
                    Text("EFIS")
                        .foregroundStyle(
                            aircraftType.efis ? .blue : .secondaryBackground
                        )
                    Text("Complex")
                        .foregroundStyle(
                            aircraftType.complex ? .blue : .secondaryBackground
                        )
                    Text("HighPerf")
                        .foregroundStyle(
                            aircraftType.highPerformance ? .blue : .secondaryBackground
                        )
                    Text("MultiPilot")
                        .foregroundStyle(
                            aircraftType.multiPilot ? .blue : .secondaryBackground
                        )
                    Text("MultiEngine")
                        .foregroundStyle(
                            aircraftType.multiEngine ? .blue : .secondaryBackground
                        )
                }
                .font(.subheadline)
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            .clipped()
            .listRowBackground(Color.theme.background)
            .swipeActions(allowsFullSwipe: false) {
                SwipeActionsView<AircraftType>(
                    item: aircraftType,
                    onDelete: onDelete,
                    onEdit: onEdit,
                    onToggleLock: onToggleLock
                )
            }
            .onTapGesture {onTapGesture()}
        }
    }
}
