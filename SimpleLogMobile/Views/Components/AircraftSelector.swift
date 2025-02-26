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
                .frame(minWidth: 70, alignment: .leading)
            if let selectedAircraft = aircraft {
                Button {
                    onTapGesture()
                } label: {
                    Text(selectedAircraft.registration ?? "Blank Registration")
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.bordered)
            } else {
                Button {
                    onTapGesture()
                } label: {
                    Text("Select aircraft")
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.theme.secondaryForeground)
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
                    try! aircraftVM.fetchAircraftList(searchType: .aircraft)
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
                                    try! aircraftVM.toggleFavorite(aircraft)
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
        try! aircraftVM.fetchAircraftList(searchType: .aircraft, searchString: searchText)
        if AppSettings.autoSelectAircraft && aircraftVM.aircraftList.count == 1 {
            DispatchQueue.main.async {
                aircraft = aircraftVM.aircraftList[0]
                dismiss()
            }
        }
    }
}
