//
//  TypeRowView.swift
//  SimpleLog
//
//  Created by Ricardo Brito Riet Correa on 1/11/25.
//

import SwiftUI

struct TypeRowView: View {
    
//    @Binding var aircraftType: AircraftType
    @ObservedObject var aircraftType: AircraftType
    let onDelete: () -> Void
    let onEdit: () -> Void
    let onTapGesture: () -> Void
    let onToggleLock: () -> Void
    
    var body: some View {
        Section(){
            HStack(alignment: .top) {
                Text(aircraftType.designator.strUnwrap)
                    .lineLimit(1)
                    .font(.title2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                VStack(alignment: .leading) {
                    Text("Maker: \(aircraftType.maker.strUnwrap)")
                        .lineLimit(1)
                    Text("Engine: \(aircraftType.engine)")
                        .lineLimit(1)
                    Text("Category: \(aircraftType.category)")
                        .lineLimit(1)
                    Text("MTOW: \(aircraftType.mtow)")
                        .lineLimit(1)
                }
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
                VStack(alignment: .leading) {
                    Text("EFIS")
                        .foregroundStyle(
                            aircraftType.efis ? .blue : Color.theme.inactive
                        )
                    Text("Complex")
                        .foregroundStyle(
                            aircraftType.complex ? .blue : Color.theme.inactive
                        )
                    Text("HighPerf")
                        .foregroundStyle(
                            aircraftType.highPerformance ? .blue : Color.theme.inactive
                        )
                    Text("MultiPilot")
                        .foregroundStyle(
                            aircraftType.multiPilot ? .blue : Color.theme.inactive
                        )
                    Text("MultiEngine")
                        .foregroundStyle(
                            aircraftType.multiEngine ? .blue : Color.theme.inactive
                        )
                }
                .font(.subheadline)
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
