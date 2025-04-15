//
//  AirportsView.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/19/25.
//

import SwiftUI
import CoreData

struct AirportsView: View {
    
    @StateObject private var airportVM = AirportViewModel()
    
    @State private var searchText: String = ""
    
    @State private var selectedAirport: Airport?
    @State private var showAddEdit = false
    @State private var showOnMap = false
    @StateObject private var alertManager = AlertManager.shared
    
    var body: some View {
        VStack {
            HStack {
                Text("Airports")
                    .font(.headline)
                TextField("ICAO, IATA, Name, City or Country", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .minimumScaleFactor(0.8)
                    .onChange(of: searchText) { oldValue , newValue in
                        do {
                            try airportVM.fetchAirportList(searchText: newValue, refresh: true)
                        } catch {
                            handleError(error)
                        }
                    }
                Button {
                    newAirport()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .bold))
                        .frame(width: 34, height: 34)
                }
            }
            .padding(.horizontal)
            if !airportVM.airportList.isEmpty {
                List {
                    ForEach($airportVM.airportList, id: \.self) { $airport in
                        AirportRowView(
                            airport: $airport,
                            onDelete: {
                                deleteAirport(airport)
                            },
                            onEdit: {
                                editAirport(airport)
                            },
                            onTapGesture: {
                                showAirport(airport)
                            },
                            onToggleLock: {
                                do {
                                    try airportVM.toggleLocked(airport)
                                } catch {
                                    handleError(error)
                                }
                            },
                            onToggleFavorite: {
                                do {
                                    try airportVM.toggleFavorite(airport)
                                } catch {
                                    handleError(error)
                                }
                            })
                        .onAppear {
                            if airport == airportVM.airportList.last {
                                do {
                                    try airportVM.fetchAirportList(offset: airportVM.airportList.count, searchText: searchText)
                                } catch {
                                    handleError(error)
                                }
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
                .listSectionSpacing(10)
            } else {
                Text(searchText.isEmpty ? "No Airports in the database." : "No Airports matching the search criteria.")
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
        .sheet(isPresented: $showAddEdit) {
            AddEditAirportView(
                $selectedAirport,
                airportVM: airportVM,
                onSave: {
                    do {
                        try airportVM.fetchAirportList(searchText: searchText, refresh: true)
                    } catch {
                        handleError(error)
                    }
                })
                .interactiveDismissDisabled()
        }
        .sheet(isPresented: $showOnMap) {
            ShowMapView(airport: $selectedAirport)
        }
        .onAppear{
            do {
                try airportVM.fetchAirportList(refresh: true)
            } catch {
                handleError(error)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(Color.theme.secondaryBackground))
        // Hides the background of the list, so the color propagates from the back
        .scrollContentBackground(.hidden)
        
    }
    
    private func showAirport(_ airport: Airport) {
        self.selectedAirport = airport
        showOnMap.toggle()
    }
    
    private func deleteAirport(_ airportToDelete: Airport) {
        
        // Verify if type has associated flight
        if airportToDelete.hasFlights {
            alertManager.showAlert(
                title: "Cannot Delete Airport",
                message: "The selected Airport cannot be deleted because it is associated with one or more flights.")
            return
        }
        
        // Verify if type has associated positioning
        if airportToDelete.hasPositioning {
            alertManager.showAlert(
                title: "Cannot Delete Airport",
                message: "The selected Airport cannot be deleted because it is associated with one or more Positioning Duty.")
            return
        }
        
        alertManager.showAlert(
            title: "Delete Airport",
            message: "Are you sure you want to delete this Airport?",
            confirmAction: {
                do {
                    try airportVM.deleteAirport(airportToDelete)
                } catch {
                    handleError(error)
                }
            }
        )
    }
    
    private func newAirport() {
        self.selectedAirport = nil
        showAddEdit.toggle()
    }
    
    private func editAirport(_ selectedAirport: Airport) {
        self.selectedAirport = selectedAirport
        showAddEdit.toggle()
    }
}
