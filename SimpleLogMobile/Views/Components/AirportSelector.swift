//
//  PlaceSelector.swift
//  SimpleLogMobile
//
//  Created by Ricardo Riet Correa on 08/02/2025.
//

import SwiftUI

struct AirportInputLine: View {
    
    @StateObject private var airportVM = AirportViewModel()
    
    @Binding var airport: Airport?
    @State var label: String
    @State private var showAirportSelector = false
    
    var body: some View {
        HStack {
            Text(label)
                .frame(minWidth: 70, alignment: .leading)
            if let selectedAirport = airport {
                Button {
                    onTapGesture()
                } label: {
                    Text(selectedAirport.toString)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.bordered)
            } else {
                Button {
                    onTapGesture()
                } label: {
                    Text("Select airport")
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.bordered)
                
            }
        }
        .sheet(isPresented: $showAirportSelector) {
            AirportSelector(airport: $airport)
        }
    }
    
    private func onTapGesture() {
        showAirportSelector.toggle()
    }
}

struct AirportSelector: View {
    
    // Environment property to dismiss the current view
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var airportVM = AirportViewModel()
    
    @Binding var airport: Airport?
    @State private var searchText: String = ""
    @State private var showAddAirportSheet = false
    @FocusState private var isSearchFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Search")
                    TextField("ICAO or IATA", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .onChange(of: searchText, onChangeOfSearchText)
                        .focused($isSearchFieldFocused)
                }
                .padding(.horizontal)
                .onAppear {
                    try! airportVM.fetchAirportList()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {  // Slight delay to ensure focus works
                        isSearchFieldFocused = true
                    }
                }
                if !airportVM.airportList.isEmpty {
                    List {
                        ForEach($airportVM.airportList, id: \.self) { $airport in
                            HStack{
                                Text(airport.toString)
                                    .minimumScaleFactor(0.7)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                    .background(Color.theme.background)
                                    .onTapGesture {
                                        self.airport = airport
                                        dismiss()
                                    }
                                    .lineLimit(1)
                                Button(action: {
                                    try! airportVM.toggleFavorite(airport)
                                }) {
                                    Image(systemName: airport.isFavorite ? "star.fill" : "star")
                                        .foregroundColor(airport.isFavorite ? .yellow : .gray)
                                        .padding(.trailing, 8)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                                .onAppear {
                                    if airport == airportVM.airportList.last {
                                        try! airportVM.fetchAirportList(offset: airportVM.airportList.count, searchText: searchText)
                                    }
                                }
                            
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
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showAddAirportSheet.toggle()
                    }) {
                        Text("New Airport")
                    }
                }
            }
            .navigationTitle("Airport Seach")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showAddAirportSheet) {
                AddEditAirportView(
                    $airport,
                    airportVM: airportVM,
                    onSave: {
                        dismiss()
                    })
                    .interactiveDismissDisabled()
            }
        }
        
    }
    
    
    
    private func onChangeOfSearchText(oldValue: String , newValue: String) {
        try! airportVM.fetchAirportList(searchText: newValue, refresh: true, searchType: .beginsWithIcaoIata)
        
        DispatchQueue.main.async {
            if AppSettings.autoSelectAirport && airportVM.airportList.count == 1 {
                airport = airportVM.airportList[0]
                dismiss()
            }
        }
    }
}
