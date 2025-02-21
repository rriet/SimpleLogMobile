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
    @StateObject var alertManager = AlertManager()
    
    var body: some View {
        VStack {
            Text("Airport")
                .font(.largeTitle)
                .padding(.vertical, 1)
            HStack {
                Text("Search:")
                TextField("ICAO, IATA, Name, City or Country", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .onChange(of: searchText) { oldValue , newValue in
                        try! airportVM.fetchAirportList(searchText: newValue, refresh: true)
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
                                try! airportVM.toggleLocked(airport)
                            },
                            onToggleFavorite: {
                                try! airportVM.toggleFavorite(airport)
                            })
                        .onAppear {
                            if airport == airportVM.airportList.last {
                                try! airportVM.fetchAirportList(offset: airportVM.airportList.count, searchText: searchText)
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
                if (searchText.isEmpty) {
                    Text("No Airports in the database.")
                        .font(.subheadline)
                        .foregroundColor(Color.theme.foreground)
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity,
                            alignment: .center
                        )
                        .background(Color.theme.secondaryBackground)
                } else {
                    Text("No Airports matching the search criteria.")
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
        }
        .alert(item: $alertManager.currentAlert) { alertInfo in
            alertManager.getAlert(alertInfo)
        }
        .sheet(isPresented: $showAddEdit) {
            AddEditAirportView(
                $selectedAirport,
                airportVM: airportVM,
                onSave: {
                    try! airportVM.fetchAirportList(searchText: searchText, refresh: true)
                })
                .interactiveDismissDisabled()
        }
        .sheet(isPresented: $showOnMap) {
            ShowMapView(airport: $selectedAirport)
        }
        .onAppear{
            try! airportVM.fetchAirportList(refresh: true)
        }
        .floatingButton(
            buttonContent: AnyView(
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .font(.title)
            ), action: newAirport)
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
            alertManager.showAlert(.simple(
                title: "Cannot Delete Airport",
                message: "The selected Airport cannot be deleted because it is associated with one or more flights."))
            return
        }
        
        // Verify if type has associated positioning
        if airportToDelete.hasPositioning {
            alertManager.showAlert(.simple(
                title: "Cannot Delete Airport",
                message: "The selected Airport cannot be deleted because it is associated with one or more Positioning Duty."))
            return
        }
        
        alertManager.showAlert(.confirmation(
            title: "Delete Airport",
            message: "Are you sure you want to delete this Airport?",
            confirmAction: {
                do {
                    try airportVM.deleteAirport(airportToDelete)
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
    
    private func newAirport() {
        self.selectedAirport = nil
        showAddEdit.toggle()
    }
    
    private func editAirport(_ selectedAirport: Airport) {
        self.selectedAirport = selectedAirport
        showAddEdit.toggle()
    }
}

