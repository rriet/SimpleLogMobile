//
//  Types.swift
//  SimpleLog
//
//  Created by Ricardo Brito Riet Correa on 1/10/25.
//

import SwiftUI
import CoreData

struct TypesView: View {
    
    @EnvironmentObject var aircraftTypeVM: AircraftTypeViewModel
    
    var groupedTypes: [String: [AircraftType]] {
        Dictionary(grouping: aircraftTypeVM.typeList, by: { $0.family ?? "" })
    }
    
    @State private var selectedType: AircraftType? = nil
    @State private var showAddEdit = false
    @StateObject var alertManager = AlertManager()
    
    var body: some View {
        VStack {
            if !groupedTypes.isEmpty {
                List {
                    ForEach(groupedTypes.keys.sorted(), id: \.self) { groupName in
                        Section(header: Text("Family: \(groupName)")){
                            ForEach(groupedTypes[groupName] ?? [], id: \.self) { aircraftType in
                                TypeRowView(
                                    aircraftType: aircraftType,
                                    onDelete: {
                                        deleteType(aircraftType)
                                    },
                                    onEdit: {
                                        editType(aircraftType)
                                    },
                                    onTapGesture: {
                                        
                                    },
                                    onToggleLock: {
                                        try! aircraftTypeVM.toggleLocked(aircraftType)
                                    }
                                )
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
                .listSectionSpacing(7)
            } else {
                Text("No types to display.\nPress the \"Plus\" button to create a new Aircraft Type.")
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
            ), action: newType)
        
        // Edit Screen
        // sheet works on all systems, but is dismissible on IOS, not dismissible on MacOS
        .sheet(isPresented: $showAddEdit) {
            AddEditTypeView($selectedType)
                .interactiveDismissDisabled()
        }
    }
    
    private func refreshList(){
        do {
            try aircraftTypeVM.fetchTypeList()
        } catch {
            alertManager.showAlert(.simple(
                title: "Unexpected error:",
                message: error.localizedDescription))
        }
    }
    
    private func newType() {
        self.selectedType = nil
        showAddEdit.toggle()
    }
    
    private func editType(_ selectedType: AircraftType) {
        self.selectedType = selectedType
        showAddEdit.toggle()
    }
    
    private func deleteType(_ typeToDelete: AircraftType) {
        
        // Verify if type has associated aircrafts
        guard typeToDelete.allowDelete else {
            alertManager.showAlert(.simple(
                title: "Cannot Delete Aircraft Type",
                message: "The selected Type cannot be deleted because it is associated with one or more Aircraft."))
            return
        }
        
        alertManager.showAlert(.confirmation(
            title: "Delete Aircraft Type",
            message: "Are you sure you want to delete this Aircraft Type?",
            confirmAction: {
                do {
                    try aircraftTypeVM.deleteType(typeToDelete)
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
}
