//
//  CrewView.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/17/25.
//

import SwiftUI
import CoreData

struct CrewsView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject private var crewVM = CrewViewModel()
    
    @State private var searchText: String = ""
    @State private var filteredCrewList: [Crew] = []
    
    var groupedFilteredCrewList: [String: [Crew]] {
        Dictionary(grouping: filteredCrewList) { crew in
            guard let name = crew.name, !name.isEmpty else { return "" }
            return String(name.prefix(1)).uppercased()
        }
    }
    
    @State private var selectedCrew: Crew?
    @State private var showCallMessageEmail = false
    @State private var showAddEdit = false
    @State private var showLargeImage = false
    @StateObject var alertManager = AlertManager()
    
    var body: some View {
        VStack {
            Text("Crew")
                .font(.largeTitle)
                .padding(.vertical, 1)
            if !crewVM.crewList.isEmpty {
                HStack {
                    Text("Search:")
                    TextField("Search", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .onChange(of: searchText) { oldValue , newValue in
                            filterCrewList()
                        }
                }
                .padding(.horizontal)
                if !filteredCrewList.isEmpty {
                    List {
                        ForEach(groupedFilteredCrewList.keys.sorted(), id: \.self) { fistLetter in
                            Section(header: Text(fistLetter)) {
                                ForEach(groupedFilteredCrewList[fistLetter] ?? [], id: \.self) { crew in
                                    CrewRowView(
                                        crew: crew,
                                        onDelete: {
                                            deleteCrew(crew)
                                        },
                                        onEdit: {
                                            editCrew(crew)
                                        },
                                        onTapGesture: {
                                            callEmail(crew)
                                        },
                                        onToggleLock: {
                                            try! crewVM.toggleLocked(crew)
                                        },
                                        onImageTapGesture: {
                                            selectedCrew = crew
                                            showLargeImage = true
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
                    Text("No Crew matching search parameters.")
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
                Text("No Crew to display.\nPress the \"Plus\" button to create a new Crewmemeber.")
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
            filterCrewList()
        }
        .onChange(of: crewVM.crewList, filterCrewList)
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
            ), action: newCrew)
        
        // Edit Screen
        // sheet works on all systems, but is dismissible on IOS, not dismissible on MacOS
        .sheet(isPresented: $showAddEdit) {
            AddEditCrewView($selectedCrew, crewVM: crewVM)
                .interactiveDismissDisabled()
        }
        .sheet(isPresented: $showLargeImage) {
            ZoomPictureView(crew: $selectedCrew)
                .presentationDetents([.medium])
        }
        .actionSheet(isPresented: $showCallMessageEmail) {
            EmailPhoneActionSheet.getActionSheet(
                email: selectedCrew?.email.strUnwrap ?? "",
                phone: selectedCrew?.phone.strUnwrap ?? ""
            )
        }
        
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(Color.theme.secondaryBackground))
    }
    
    private func callEmail(_ crewToCall: Crew) {
        guard normalizeEmail(crewToCall.email.strUnwrap) != nil || normalizePhoneNumber(crewToCall.phone.strUnwrap) != nil else {
            return // Return early if both email and phone are nil
        }
        
        // Only proceed if both email and phone are valid
        selectedCrew = crewToCall
        showCallMessageEmail = true
    }
    
    private func filterCrewList() {
        if searchText.isEmpty {
            filteredCrewList = crewVM.crewList
        } else {
            filteredCrewList = crewVM.crewList.filter { crew in
                crew.name.strUnwrap.localizedCaseInsensitiveContains(searchText) ||
                crew.phone.strUnwrap.localizedCaseInsensitiveContains(searchText) ||
                crew.email.strUnwrap.localizedCaseInsensitiveContains(searchText) ||
                crew.notes.strUnwrap.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private func deleteCrew(_ crewToDelete: Crew) {
        
        // Verify if type has associated flight
        if crewToDelete.hasFlights {
            alertManager.showAlert(.simple(
                title: "Cannot Delete Crew",
                message: "The selected Crewmember cannot be deleted because it is associated with one or more flights."))
            return
        }
        
        // Verify if type has associated simulator
        if crewToDelete.hasSimTrainingArray {
            alertManager.showAlert(.simple(
                title: "Cannot Delete Crew",
                message: "The selected Crewmember cannot be deleted because it is associated with one or more Simulator Trining."))
            return
        }
        
        alertManager.showAlert(.confirmation(
            title: "Delete Crew",
            message: "Are you sure you want to delete this Crewmember?",
            confirmAction: {
                do {
                    try crewVM.deleteCrew(crewToDelete)
                    try crewVM.fetchCrewList()
                    filterCrewList()
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
    
    private func newCrew() {
        self.selectedCrew = nil
        showAddEdit.toggle()
    }
    
    private func editCrew(_ selectedCrew: Crew) {
        self.selectedCrew = selectedCrew
        showAddEdit.toggle()
    }
}

