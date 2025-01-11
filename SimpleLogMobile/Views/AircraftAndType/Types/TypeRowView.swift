//
//  TypeRowView.swift
//  SimpleLog
//
//  Created by Ricardo Brito Riet Correa on 1/11/25.
//

import SwiftUI

struct TypeRowView: View {
    
    var aircraft: AircraftType
    let onDelete: () -> Void
    let onEdit: () -> Void
    let onTapGesture: () -> Void
    let onToggleLock: () -> Void
    
    var body: some View {
        Section(){
            HStack(alignment: .top) {
                Text(aircraft.name.strUnwrap)
                    .font(.title2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                VStack(alignment: .leading) {
                    Text("Maker: \(aircraft.maker.strUnwrap) lkjsdhf sldkjhf lasdfgh salkfg aksdjhfg")
                    Text("Engine: \(aircraft.engineType.strUnwrap)")
                    Text("Category: \(aircraft.categoryString.strUnwrap)")
                    Text("MTOW: \(aircraft.mtow)")
                }
                .font(.subheadline)
                .frame(maxWidth: .infinity)
                VStack(alignment: .leading) {
                    Text("EFIS")
                        .foregroundStyle(
                            aircraft.efis ? .blue : .secondaryBackground
                        )
                    Text("Complex")
                        .foregroundStyle(
                            aircraft.complex ? .blue : .secondaryBackground
                        )
                    Text("HighPerf")
                        .foregroundStyle(
                            aircraft.highPerformance ? .blue : .secondaryBackground
                        )
                    Text("MultiPilot")
                        .foregroundStyle(
                            aircraft.multiPilot ? .blue : .secondaryBackground
                        )
                    Text("MultiEngine")
                        .foregroundStyle(
                            aircraft.multiEngine ? .blue : .secondaryBackground
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
