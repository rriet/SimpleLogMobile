//
//  AircraftsView.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/11/25.
//

import SwiftUI
import CoreData

struct AircraftsView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject var aircraftTypeVM: AircraftTypeViewModel
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Aircraft.aircraftType?.designator, ascending: true),
            NSSortDescriptor(keyPath: \Aircraft.registration, ascending: true)
        ],
        animation: .default
    )
    private var aircraftList: FetchedResults<Aircraft>
    
    var groups: [String: [Aircraft]] {
        Dictionary(
            grouping: aircraftList,
            by: { $0.getType.designator.strUnwrap }
        )
    }
    
    @State private var selectedAircraft: Aircraft?
    @State private var showAddEdit = false
    @StateObject var alertManager = AlertManager()
    
    var body: some View {
        VStack {
            if !groups.isEmpty {
                List {
                    ForEach(groups.keys.sorted(), id: \.self) { groupName in
                        Text("Type: \(groupName)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .listRowBackground(
                                Color(Color.theme.secondaryBackground)
                            )
                        ForEach(groups[groupName] ?? [], id: \.self) { aircraft in
                            AircraftRowView(
                                aircraft: aircraft,
                                onDelete: {
                                    viewContext.delete(aircraft)
                                    do {
                                        try viewContext.save()
                                        try aircraftTypeVM.fetchTypeData()
                                    } catch {
                                        print("Failed to delete aircraft: \(error.localizedDescription)")
                                    }
                                },
                                onEdit: {
                                    
                                },
                                onTapGesture: {
                                    
                                },
                                onToggleLock: {
                                    
                                })
                        }
                    }
                }
                .listSectionSpacing(7)
            } else {
                Text("No Aircraft to display.\nPress the \"Plus\" button to create a new Aircraft.")
                    .font(.subheadline)
                    .foregroundColor(Color.theme.foreground)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .center
                    )
                    .background(Color.theme.secondaryBackground)
            }
        }
        // Hides the background of the list, so the color propagates from the back
        .scrollContentBackground(.hidden)
        .floatingButton(
            buttonContent: AnyView(
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .font(.title)
            ),
            action: {
                showAddEdit.toggle()
            }
        )
        
        // Edit Screen
        // sheet works on all systems, but is dismissible on IOS, not dismissible on MacOS
        .sheet(isPresented: $showAddEdit) {
            // TODO:
        }
    }
    
}

