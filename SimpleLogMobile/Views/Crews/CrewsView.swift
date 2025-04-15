//
//  CrewView.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/17/25.
//

import SwiftUI
import CoreData

struct CrewsView: View {
    
    @StateObject private var crewVM = CrewViewModel()
    
    @State private var searchText: String = ""
    
    @State private var selectedCrew: Crew?
    @State private var showCallMessageEmail = false
    @State private var showAddEdit = false
    @State private var showLargeImage = false
    @StateObject private var alertManager = AlertManager.shared
    
    var body: some View {
        ZStack{
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
                    Button {
                        newCrew()
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .bold))
                            .frame(width: 34, height: 34)
                    }
                }
                .padding(.horizontal)
                if !crewVM.crewList.isEmpty {
                    List {
                        ForEach(crewVM.crewList, id: \.self) { crew in
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
                                    do {
                                        try crewVM.toggleLocked(crew)
                                    } catch {
                                        handleError(error)
                                    }
                                },
                                onImageTapGesture: {
                                    selectedCrew = crew
                                    showLargeImage = true
                                },
                                onToggleFavorite: {
                                    do {
                                        try crewVM.toggleFavorite(crew)
                                    } catch {
                                        handleError(error)
                                    }
                                })
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
            VStack{
                Spacer()
                Text("")
                    .confirmationDialog("Contact", isPresented: $showCallMessageEmail) {
                        EmailPhoneView(
                            phone: selectedCrew?.phone ?? "",
                            email: selectedCrew?.email ?? ""
                        )
                    }
            }
        }
        // Hides the background of the list, so the color propagates from the back
        .scrollContentBackground(.hidden)
        
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
        .onAppear {
            do {
                try crewVM.fetchCrewList(refresh: true)
            } catch {
                handleError(error)
            }
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
    
    private func deleteCrew(_ crewToDelete: Crew) {
        
        // Verify if type has associated flight
        if crewToDelete.hasFlights {
            alertManager.showAlert(
                title: "Cannot Delete Crew",
                message: "The selected Crewmember cannot be deleted because it is associated with one or more flights.")
            return
        }
        
        // Verify if type has associated simulator
        if crewToDelete.hasSimTrainingArray {
            alertManager.showAlert(
                title: "Cannot Delete Crew",
                message: "The selected Crewmember cannot be deleted because it is associated with one or more Simulator Trining.")
            return
        }
        
        alertManager.showAlert(
            title: "Delete Crew",
            message: "Are you sure you want to delete this Crewmember?",
            confirmAction: {
                do {
                    try crewVM.deleteCrew(crewToDelete)
                    try crewVM.fetchCrewList()
                } catch {
                    handleError(error)
                }
            }
        )
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

