//
//  CrewSelector.swift
//  SimpleLogMobile
//
//  Created by Ricardo Riet Correa on 15/04/2025.
//

import SwiftUI

struct CrewButton: View {
    
    @StateObject private var crewVM = CrewViewModel()
    
    @Binding var crewList: [Crew: CrewPosition]
    
    @State private var showCrewSelector = false
    
    private var countCrew: Int {
        crewList.count
    }
    
    var body: some View {
        Button {
            showCrewSelector.toggle()
        } label: {
            Text("Crew")
            .overlay(
                ZStack {
                    if countCrew > 0 {
                        Text("\(countCrew)")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(6)
                            .background(Color.red)
                            .clipShape(Circle())
                            .offset(x: 17, y: -15)
                    }
                },
                alignment: .topTrailing
            )
        }
        .buttonStyle(.bordered)
        .sheet(isPresented: $showCrewSelector) {
            CrewSelector(crewList: $crewList)
        }
    }
    
}

struct CrewSelector: View {
    
    // Environment property to dismiss the current view
    @Environment(\.dismiss) var dismiss
    
    @Binding var crewList: [Crew: CrewPosition]
    
    @State private var showSelectCrewSheet = false
    
    @State private var positions: CrewPosition = .PIC
    
    var body: some View {
        NavigationStack {
            VStack {
                Grid(
                    alignment: .centerFirstTextBaseline,
                    horizontalSpacing: 8,
                    verticalSpacing: 5
                ) {
                    let crewArray = Array(crewList.keys)
                    if crewArray.isEmpty {
                        Text("No Crew selected for this flight.")
                            .font(.subheadline)
                            .foregroundColor(Color.theme.foreground)
                            .frame(
                                maxWidth: .infinity,
                                maxHeight: .infinity,
                                alignment: .center
                            )
                    } else {
                        ForEach(crewArray, id: \.objectID) { crew in
                            GridRow {
                                Text(crew.name ?? "")
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .minimumScaleFactor(0.8)
                                Picker("Position", selection: $crewList[crew]) {
                                    ForEach(CrewPosition.allCases, id: \.self) { position in
                                        Text(position.rawValue).tag(position)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle()) // You can use other styles like .segmented or .wheel
                                .font(.caption)
                                
                                Button {
                                    crewList.removeValue(forKey: crew)
                                } label: {
                                    Image(systemName: "person.badge.minus")
                                        .font(.system(size: 15, weight: .bold))
                                }
                                .padding(6)
                                .buttonStyle(.bordered)
                                .foregroundColor(.red)
                            }
                        }
                    }
                }
                .font(.headline)
                .lineLimit(1)
                .padding(.horizontal)
                Spacer()
                
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showSelectCrewSheet = true
                    }) {
                        Text("Add Crew")
                    }
                }
            }
            .navigationTitle("Crew On Board")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showSelectCrewSheet) {
                SelectCrewSheet(
                    onSelect: { selectedCrew in
                        crewList[selectedCrew] = .PIC
                    }
                )
            }
        }
        
    }
}

struct SelectCrewSheet: View {
    // Environment property to dismiss the current view
    @Environment(\.dismiss) var dismiss
    
    var onSelect: (Crew) -> Void
    
    @StateObject private var crewVM = CrewViewModel()
    
    @State private var searchText: String = ""
    @State private var showAddEditCrew: Bool = false
    @State private var selectedCrew: Crew?
    @FocusState private var isSearchFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Crew")
                        .font(.headline)
                    TextField("Name, email, phone or notes", text: $searchText)
                        .autocorrectionDisabled(true)
                        .minimumScaleFactor(0.8)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: searchText) { oldValue , newValue in
                            do {
                                try crewVM.fetchCrewList(searchText: newValue, refresh: true)
                            } catch {
                                handleError(error)
                            }
                        }
                        .focused($isSearchFieldFocused)
                        .onAppear {
                            do {
                                try crewVM.fetchCrewList(refresh: true)
                            } catch {
                                handleError(error)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                isSearchFieldFocused = true
                            }
                        }
                }
                .padding(.horizontal)
                if !crewVM.crewList.isEmpty {
                    List {
                        ForEach(crewVM.crewList, id: \.self) { crew in
                            Text(crew.name.strUnwrap)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                .onTapGesture {
                                    onSelect(crew)
                                    dismiss()
                                }
                                .lineLimit(1)
                                .onAppear {
                                    if crew == crewVM.crewList.last {
                                        do {
                                            try crewVM.fetchCrewList(offset: crewVM.crewList.count, searchText: searchText)
                                        } catch {
                                            handleError(error)
                                        }
                                    }
                                }
                        }
                    }
                    .listSectionSpacing(10)
                } else {
                    Text(searchText.isEmpty ? "No Crew in the database." : "No Crew matching the search criteria.")
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
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showAddEditCrew.toggle()
                    }) {
                        Text("New Crew")
                    }
                }
            }
            .navigationTitle("Crew On Board")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showAddEditCrew) {
                AddEditCrewView($selectedCrew,
                                crewVM: crewVM,
                                onSave: { newCrew in
                                    onSelect(newCrew!)
                                    dismiss()
                                }
                )
                    .interactiveDismissDisabled()
            }
//            .onChange(of: selectedCrew) { oldValue , newValue in
////                onSelect(newValue)
//                dismiss()
//            }
        }
    }
}
