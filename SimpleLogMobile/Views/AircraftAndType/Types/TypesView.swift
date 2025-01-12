//
//  Types.swift
//  SimpleLog
//
//  Created by Ricardo Brito Riet Correa on 1/10/25.
//

import SwiftUI
import CoreData

struct TypesView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \AircraftType.family, ascending: true),
                          NSSortDescriptor(keyPath: \AircraftType.name, ascending: true)],
        animation: .default)
    private var typeList: FetchedResults<AircraftType>
    
    var groups: [String: [AircraftType]] {
        Dictionary(
            grouping: typeList,
            by: { $0.family ?? "" }
        )
    }
    
    @State private var selectedType: AircraftType?
    @State private var showAddEdit = false
    @StateObject var alertManager = AlertManager()
    
    var body: some View {
        VStack {
            if !groups.isEmpty {
                List {
                    ForEach(groups.keys.sorted(), id: \.self) { groupName in
                        Text("Family: \(groupName)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .listRowBackground(
                                Color(Color.theme.secondaryBackground)
                            )
                        ForEach(groups[groupName] ?? [], id: \.self) { aircraftType in
                            TypeRowView(
                                aircraftType: aircraftType,
                                onDelete: {
                                    
                                },
                                onEdit: {
                                    
                                },
                                onTapGesture: {
                                    
                                },
                                onToggleLock: {
                                    
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
                addRandomTypes()
            }
        )
        
        // Edit Screen
        // sheet works on all systems, but is dismissible on IOS, not dismissible on MacOS
        .sheet(isPresented: $showAddEdit) {
            // TODO:
        }
    }
    
    func addRandomTypes() {
        withAnimation {
            let newType = AircraftType(context: viewContext)
            newType.name = "A321"
            newType.family = "A320"
            newType.maker = "Airbus"
            newType.efis = true
            newType.complex = true
            newType.isLocked = true
            
            let newType2 = AircraftType(context: viewContext)
            newType2.name = "A319"
            newType2.family = "A320"
            newType2.maker = "Airbus"
            newType2.efis = true
            newType2.complex = true
            newType2.isLocked = true
            
            let newType3 = AircraftType(context: viewContext)
            newType3.name = "B788"
            newType3.family = "B787"
            newType3.maker = "Boeing"
            newType3.efis = true
            newType3.highPerformance = true
            newType3.complex = true
            newType3.isLocked = true
            
            let newBird = Aircraft(context: viewContext)
            newBird.aircraftType = newType
            newBird.registration = "A7-ABC"
            newBird.aircraftMtow = 0
            
            let newBird2 = Aircraft(context: viewContext)
            newBird2.aircraftType = newType
            newBird2.registration = "ABC"
            newBird2.aircraftMtow = 10000
            
            let newBird3 = Aircraft(context: viewContext)
            newBird3.aircraftType = newType2
            newBird3.registration = "A7-PTU"
            newBird3.aircraftMtow = 0
            
            let newBird4 = Aircraft(context: viewContext)
            newBird4.aircraftType = newType3
            newBird4.registration = "PT-CPU"
            newBird4.aircraftMtow = 0
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

//#Preview {
//    Types()
//}
