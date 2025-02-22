//
//  AircraftSelector.swift
//  SimpleLogMobile
//
//  Created by Ricardo Riet Correa on 22/02/2025.
//

import SwiftUI

struct AircraftInputLine: View {
    
    @StateObject private var aircraftVM = AircraftViewModel()
    
    @Binding var aircraft: Aircraft?
    @State private var showAircraftSelector = false
    
    var body: some View {
        HStack {
            Text("Aircraft")
            if let selectedAircraft = aircraft {
                Button {
                    onTapGesture()
                } label: {
                    Text(selectedAircraft.registration ?? "Blank Registration")
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                }
                .buttonStyle(.bordered)
            } else {
                Button {
                    onTapGesture()
                } label: {
                    Text("Click to select an aircraft")
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.bordered)
                
            }
        }
        .sheet(isPresented: $showAircraftSelector) {
            AircraftSelector(aircraft: $aircraft)
        }
    }
    private func onTapGesture() {
        showAircraftSelector.toggle()
    }
}

struct AircraftSelector: View {
    
    // Environment property to dismiss the current view
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var aircraftVM = AircraftViewModel()
    
    @Binding var aircraft: Aircraft?
    @State private var searchText: String = ""
    @State private var showAddAirportSheet = false
    @FocusState private var isSearchFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
//            VStack {
//                HStack {
//                    Text("Search")
//                    TextField("Registration", text: $searchText)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                        .textInputAutocapitalization(.characters)
//                        .autocorrectionDisabled()
//                        .onChange(of: searchText, onChangeOfSearchText)
//                        .focused($isSearchFieldFocused)
//                    Button {
//                        aircraft = nil
//                        showAddAirportSheet = true
//                    } label: {
//                        Image(systemName: "plus") // Use an Image
//                            .font(.system(size: 20, weight: .bold))
//                            .frame(width: 44, height: 20)
//                    }
//                    .buttonStyle(.bordered)
//                }
//                .padding(.horizontal)
//                .onAppear {
//                    try! aircraftVM.fetchAircraftList()
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {  // Slight delay to ensure focus works
//                        isSearchFieldFocused = true
//                    }
//                }
//                if !aircraftVM.aircraftList.isEmpty {
//                    List {
//                        ForEach(aircraftVM.aircraftList, id: \.self) { $aircraft in
//                            Text(aircraft.registration ?? "Blank Registration")
//                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
//                                .background(Color.theme.background)
//                                .onTapGesture {
//                                    self.aircraft = aircraft
//                                    dismiss()
//                                }
//                                .lineLimit(1)
//                                .onAppear {
//                                    if aircraft == aircraftVM.aircraftList.last {
//                                        try! aircraftVM.fetchAircraftList()
////                                        (offset: airportVM.airportList.count, searchText: searchText)
//                                    }
//                                }
//                            
//                        }
//                    }
//                    .listSectionSpacing(10)
//                } else {
//                    if (searchText.isEmpty) {
//                        Text("No Aircraft in the database.")
//                            .font(.subheadline)
//                            .foregroundColor(Color.theme.foreground)
//                            .frame(
//                                maxWidth: .infinity,
//                                maxHeight: .infinity,
//                                alignment: .center
//                            )
//                            .background(Color.theme.secondaryBackground)
//                    } else {
//                        Text("No Aircraft matching the search criteria.")
//                            .font(.subheadline)
//                            .foregroundColor(Color.theme.foreground)
//                            .frame(
//                                maxWidth: .infinity,
//                                maxHeight: .infinity,
//                                alignment: .center
//                            )
//                            .background(Color.theme.secondaryBackground)
//                    }
//                }
//            }
//            .toolbar {
//                ToolbarItem(placement: .cancellationAction) {
//                    Button("Cancel") {
//                        dismiss()
//                    }
//                }
//            }
//            .navigationTitle("Airport Seach")
//            .navigationBarTitleDisplayMode(.inline)
//            .sheet(isPresented: $showAddAirportSheet) {
//                AddEditAircraftView(
//                    $aircraft,
////                    aircraftVM: aircraftVM,
//                    onSave: {
//                        dismiss()
//                    })
//                    .interactiveDismissDisabled()
//            }
        }
        
    }
    
    private func onChangeOfSearchText(oldValue: String , newValue: String) {
        try! aircraftVM.fetchAircraftList()
//        (searchText: newValue, refresh: true, searchType: .beginsWithIcaoIata)
        DispatchQueue.main.async {
            if aircraftVM.aircraftList.count == 1 {
                aircraft = aircraftVM.aircraftList[0]
                dismiss()
            }
        }
    }
}
