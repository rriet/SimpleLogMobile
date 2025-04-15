//
//  CrewSelector.swift
//  SimpleLogMobile
//
//  Created by Ricardo Riet Correa on 15/04/2025.
//

import SwiftUI

struct CrewSelector: View {
    
    // Environment property to dismiss the current view
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var aircraftVM = AircraftViewModel()
    @StateObject var aircraftTypeVM = AircraftTypeViewModel()
    
    @Binding var aircraft: Aircraft?
    @State private var searchText: String = ""
    @State private var showAddAircraftSheet = false
    @FocusState private var isSearchFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Search")
                    TextField("Registration or Type", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .onChange(of: searchText, onChangeOfSearchText)
                        .focused($isSearchFieldFocused)
                }
                .padding()
                .onAppear {
                    do {
                        try aircraftVM.fetchAircraftList(searchType: .aircraft)
                    } catch {
                        handleError(error)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isSearchFieldFocused = true
                    }
                }
                if !aircraftVM.aircraftList.isEmpty {
                    List {
                        ForEach($aircraftVM.aircraftList, id: \.self) { $aircraft in
                            HStack{
                                Text(aircraft.toString)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                    .background(Color.theme.background)
                                    .onTapGesture {
                                        self.aircraft = aircraft
                                        dismiss()
                                    }
                                    .lineLimit(1)
                                Button(action: {
                                    do {
                                        try aircraftVM.toggleFavorite(aircraft)
                                    } catch {
                                        handleError(error)
                                    }
                                }) {
                                    Image(systemName: aircraft.isFavorite ? "star.fill" : "star")
                                        .foregroundColor(aircraft.isFavorite ? .yellow : .gray)
                                        .padding(.trailing, 8)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                            
                        }
                    }
                } else {
                    if (searchText.isEmpty) {
                        Text("No Aircraft in the database.")
                            .font(.subheadline)
                            .foregroundColor(Color.theme.foreground)
                            .frame(
                                maxWidth: .infinity,
                                maxHeight: .infinity,
                                alignment: .center
                            )
                            .background(Color.theme.secondaryBackground)
                    } else {
                        Text("No Aircraft matching the search criteria.")
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
                        aircraft = nil
                        showAddAircraftSheet = true
                    }) {
                        Text("New Aircraft")
                    }
                }
            }
            .navigationTitle("Airport Seach")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showAddAircraftSheet) {
                    AddEditAircraftView(
                        $aircraft,
                        onSave: {
                            dismiss()
                        })
                        .environmentObject(aircraftTypeVM)
                        .interactiveDismissDisabled()
            }
        }
        
    }
    
    private func onChangeOfSearchText(oldValue: String , newValue: String) {
        do {
            try aircraftVM.fetchAircraftList(searchType: .aircraft, searchString: searchText)
        } catch {
            handleError(error)
        }
        if AppSettings.autoSelectAircraft && aircraftVM.aircraftList.count == 1 {
            DispatchQueue.main.async {
                aircraft = aircraftVM.aircraftList[0]
                dismiss()
            }
        }
    }
}
