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
            by: { $0.family ?? "Unknown" }
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
                        ForEach(groups[groupName] ?? [], id: \.self) { aircraft in
                            TypeRowView(
                                aircraft: aircraft,
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
            let newItem = AircraftType(context: viewContext)
            newItem.name = "B788"
            newItem.family = "B787"
            newItem.maker = "Boeing"
            newItem.efis = true
            newItem.complex = true
            newItem.isLocked = true
            
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
