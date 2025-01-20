//
//  AirportsView.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/19/25.
//

import SwiftUI
import CoreData

struct AirportsView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject private var airportVM = AirportViewModel()
    
    @State private var searchText: String = ""
    @State private var filteredAirportList: [Airport] = []
    
    var groupedFilteredAirportList: [String: [Airport]] {
        Dictionary(grouping: filteredAirportList) { airport in
            guard let icao = airport.icao, !icao.isEmpty else { return "" }
            return String(icao.prefix(1)).uppercased()
        }
    }
    
    @State private var selectedAirport: Airport?
    @State private var showAddEdit = false
    @StateObject var alertManager = AlertManager()
    
    var body: some View {
        VStack {
            Text("Airport")
                .font(.largeTitle)
                .padding(.vertical, 1)
            if !airportVM.airportList.isEmpty {
                HStack {
                    Text("Search:")
                    TextField("Search", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .onChange(of: searchText) { oldValue , newValue in
                            filterAirportList()
                        }
                }
                .padding(.horizontal)
                if !groupedFilteredAirportList.isEmpty {
                    List {
                        ForEach(groupedFilteredAirportList.keys.sorted(), id: \.self) { fistLetter in
                            Section(header: Text(fistLetter)) {
                                ForEach(groupedFilteredAirportList[fistLetter] ?? [], id: \.self) { airport in
                                    AirportRowView(
                                        airport: airport,
                                        onDelete: {
                                            deleteAirport(airport)
                                        },
                                        onEdit: {
                                            editAirport(airport)
                                        },
                                        onTapGesture: {
                                            
                                        },
                                        onToggleLock: {
                                            try! airportVM.toggleLocked(airport)
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
                    .listSectionSpacing(10)
                } else {
                    Text("No Airport matching search parameters.")
                        .font(.subheadline)
                        .foregroundColor(Color.theme.foreground)
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity,
                            alignment: .center
                        )
                        .background(Color.theme.secondaryBackground)
                }
            } else {
                Text("No Airport to display.\nPress the \"Plus\" button to create a new Airport.")
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
        .onAppear {
            filterAirportList()
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
            ), action: newAirport)
        
        // Edit Screen
        // sheet works on all systems, but is dismissible on IOS, not dismissible on MacOS
        .sheet(isPresented: $showAddEdit) {
            AddEditAirportView($selectedAirport, airportVM: airportVM)
                .interactiveDismissDisabled()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(Color.theme.secondaryBackground))
        .onChange(of: airportVM.airportList, filterAirportList)
    }
    
    private func filterAirportList() {
        if searchText.isEmpty {
            filteredAirportList = airportVM.airportList
        } else {
            filteredAirportList = airportVM.airportList.filter { airport in
                airport.icao.strUnwrap.localizedCaseInsensitiveContains(searchText) ||
                airport.iata.strUnwrap.localizedCaseInsensitiveContains(searchText) ||
                airport.name.strUnwrap.localizedCaseInsensitiveContains(searchText) ||
                airport.country.strUnwrap
                    .localizedCaseInsensitiveContains(searchText)
            }
        }
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
                    try airportVM.fetchAirportList()
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

