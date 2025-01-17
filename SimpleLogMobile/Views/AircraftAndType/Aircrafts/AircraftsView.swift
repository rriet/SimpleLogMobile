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
    @ObservedObject private var aircraftVM = AircraftViewModel()
    
    var groupedAircrafts: [String: [Aircraft]] {
        Dictionary(
            grouping: aircraftVM.aircraftList,
            by: {$0.aircraftType?.designatorUnwrapped ?? ""})
    }
    
    @State private var selectedAircraft: Aircraft?
    @State private var showAddEdit = false
    @StateObject var alertManager = AlertManager()
    
    var body: some View {
        VStack {
            if !groupedAircrafts.isEmpty {
                List {
                    ForEach(groupedAircrafts.keys.sorted(), id: \.self) { groupName in
                        Section(header: Text("Type: \(groupName)")){
                            ForEach(groupedAircrafts[groupName] ?? [], id: \.self) { aircraft in
                                AircraftRowView(
                                    aircraft: aircraft,
                                    onDelete: {
                                        deleteAircraft(aircraft)
                                    },
                                    onEdit: {
                                        editAircraft(aircraft)
                                    },
                                    onTapGesture: {
                                        
                                    },
                                    onToggleLock: {
                                        try! aircraftVM.toggleLocked(aircraft)
                                    })
                            }
                        }
                    }
                }
                .listSectionSpacing(5)
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
        .alert(item: $alertManager.currentAlert) { alertInfo in
            alertManager.getAlert(alertInfo)
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
            AddEditAircraftView($selectedAircraft)
                .interactiveDismissDisabled()
        }
    }
    
    private func deleteAircraft(_ aircraftToDelete: Aircraft) {
        
        print(aircraftToDelete.hasFlights)
        
        // Verify if type has associated flight
        if aircraftToDelete.hasFlights {
            alertManager.showAlert(.simple(
                title: "Cannot Delete Aircraft",
                message: "The selected Aircraft cannot be deleted because it is associated with one or more flights."))
            return
        }
        
        // Verify if type has associated simulator
        if aircraftToDelete.hasSimTrainingArray {
            alertManager.showAlert(.simple(
                title: "Cannot Delete Aircraft",
                message: "The selected Aircraft cannot be deleted because it is associated with one or more Simulator Trining."))
            return
        }
        
        alertManager.showAlert(.confirmation(
            title: "Delete Aircraft",
            message: "Are you sure you want to delete this Aircraft?",
            confirmAction: {
                do {
                    try aircraftVM.deleteAircraft(aircraftToDelete)
                    try aircraftVM.fetchAircraftData()
                    try aircraftTypeVM.fetchTypeData()
                } catch let details as ErrorDetails {
                    alertManager.showAlert(.error(details: details))
                } catch {
                    alertManager.showAlert(.simple(
                        title: "Unexpected error:",
                        message: error.localizedDescription))
                }
            }
        ))
    }
    
    private func newAircraft() {
        self.selectedAircraft = nil
        showAddEdit.toggle()
    }
    
    private func editAircraft(_ selectedAircraft: Aircraft) {
        self.selectedAircraft = selectedAircraft
        showAddEdit.toggle()
    }
    
}

