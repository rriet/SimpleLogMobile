//
//  AircraftsView.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/11/25.
//

import SwiftUI
import CoreData

struct AircraftsView: View {
    
    @EnvironmentObject var aircraftTypeVM: AircraftTypeViewModel
    @StateObject private var aircraftVM = AircraftViewModel()
    
    @State private var selectedAircraft: Aircraft?
    @State private var showAddEdit = false
    @State private var searchText: String = ""
    @StateObject var alertManager = AlertManager()
    
    var groupedAircrafts: [String: [Aircraft]] {
        // Get favorite aircrafts
        let favoriteAircrafts = aircraftVM.aircraftList.filter { $0.isFavorite }

        var sortedGrouped: [String: [Aircraft]] = [:]
        if !favoriteAircrafts.isEmpty {
            sortedGrouped["Favorites"] = favoriteAircrafts
        }
        
        let grouped = Dictionary(
            grouping: aircraftVM.aircraftList,
            by: {$0.aircraftType?.designatorUnwrapped ?? ""})
        
        sortedGrouped.merge(grouped) { current, _ in current }

        return sortedGrouped
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Aircrafts")
                    .font(.headline)
                TextField("Registration or Type", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .padding(.horizontal)
                    .onChange(of: searchText, onChangeOfSearchText)
                Button {
                    newAircraft()
                } label: {
                    Image(systemName: "plus") // Use an Image
                        .font(.system(size: 20, weight: .bold))
                        .frame(width: 34, height: 34)
                }
            }
            .padding(.horizontal)
            if !groupedAircrafts.isEmpty {
                List {
                    ForEach(groupedAircrafts.keys.sorted{ (key1, key2) -> Bool in
                        if key1 == "Favorites" { return true }
                        if key2 == "Favorites" { return false }
                        return key1 < key2
                    }, id: \.self) { groupName in
                        Section(header: Text(groupName == "Favorites" ? groupName : "Type: \(groupName)")){
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
                                    },
                                    onToggleFavorite: {
                                        try! aircraftVM.toggleFavorite(aircraft)
                                    })
                            }
                        }
                    }
                    // Spacer to allow last entry to scroll pass the + button
                    Section {
                        Spacer()
                            .frame(height: 100)
                            .listRowBackground(Color.clear)
                    }
                }
                .listSectionSpacing(5)
            } else {
                Text("No Aircrafts to yet.")
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
        
        // Edit Screen
        // sheet works on all systems, but is dismissible on IOS, not dismissible on MacOS
        .sheet(isPresented: $showAddEdit) {
            AddEditAircraftView($selectedAircraft, onSave: {
                refreshList()
                try! aircraftTypeVM.fetchTypeList()
            })
                .interactiveDismissDisabled()
        }
        .onAppear{
            refreshList()
        }
    }
    
    private func refreshList(){
        do {
            try aircraftVM.fetchAircraftList()
        } catch {
            alertManager.showAlert(.simple(
                title: "Unexpected error:",
                message: error.localizedDescription))
        }
    }
    
    private func onChangeOfSearchText(oldValue: String , newValue: String) {
        
        try! aircraftVM.fetchAircraftList(searchString: newValue, includeType: true)
    }
    
    private func deleteAircraft(_ aircraftToDelete: Aircraft) {
        
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
                    try aircraftVM.fetchAircraftList()
                    try aircraftTypeVM.fetchTypeList()
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

