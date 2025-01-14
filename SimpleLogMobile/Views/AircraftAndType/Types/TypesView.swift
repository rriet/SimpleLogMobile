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
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \AircraftType.family, ascending: true),
            NSSortDescriptor(keyPath: \AircraftType.name, ascending: true)
        ],
        animation: .default
    )
    private var typeList: FetchedResults<AircraftType>
    
    @State private var selectedType: AircraftType? = nil
    @State private var showAddEdit = false
    @StateObject var alertManager = AlertManager()
    
    var body: some View {
        VStack {
            if !aircraftTypeVM.groupedTypeArray.isEmpty {
                List {
                    ForEach(
                        aircraftTypeVM.groupedTypeArray.keys.sorted(),
                        id: \.self
                    ) { groupName in
                        Text("Family: \(groupName)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .listRowBackground(
                                Color(Color.theme.secondaryBackground)
                            )
                        ForEach(aircraftTypeVM.groupedTypeArray[groupName] ?? [], id: \.self) { aircraftType in
                            TypeRowView(
                                aircraftType: aircraftType,
                                onDelete: {
                                    deleteType(aircraftType)
                                },
                                onEdit: {

                                },
                                onTapGesture: {
                                    
                                },
                                onToggleLock: {
                                    aircraftTypeVM.toggleLocked(aircraftType)
                                }
                            )
                        }
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
//        .onAppear(){
//            typeVM.fetchTypeData()
//        }
//        .onChange(of: refreshTypes) {
//            print("Teste")
//            refreshTypes.toggle()
//            typeVM.fetchTypeData()
//        }
        // Hides the background of the list, so the color propagates from the back
        .scrollContentBackground(.hidden)
        .floatingButton(
            buttonContent: AnyView(
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .font(.title)
            ),
            action: {
//                showAddEdit.toggle()
                aircraftTypeVM.addRandomTypes()
            }
        )
        
        // Edit Screen
        // sheet works on all systems, but is dismissible on IOS, not dismissible on MacOS
        .sheet(isPresented: $showAddEdit) {
            // TODO:
        }
    }
    
    private func deleteType(_ typeToDelete: AircraftType) {
        guard typeToDelete.allowDelete else {
            alertManager.showAlert(.simple(
                title: "Cannot Delete Aircraft",
                message: "The selected aircraft cannot be deleted because it is associated with one or more flights."))
            return
        }
        
        alertManager.showAlert(.confirmation(
            title: "Delete Aircraft",
            message: "Are you sure you want to delete this aircraft?",
            confirmAction: {
                aircraftTypeVM.deleteType(typeToDelete)
            }
        ))
    }
}

//#Preview {
//    Types()
//}
