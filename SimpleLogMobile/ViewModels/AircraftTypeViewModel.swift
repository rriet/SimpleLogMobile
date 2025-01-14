//
//  TypeViewModel.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/11/25.
//

import Foundation
import CoreData

class AircraftTypeViewModel: ObservableObject {
    
    static let shared = AircraftTypeViewModel()
    private let viewContext = PersistenceController.shared.viewContext
    @Published var groupedTypeArray: [String: [AircraftType]] = [:]
    
    private init() {
        fetchTypeData()
    }
    
    func unload() {
        groupedTypeArray = [:]
    }
    
    func fetchTypeData() {
        let request = NSFetchRequest<AircraftType>(entityName: "AircraftType")
        let sort = NSSortDescriptor(key: "family", ascending: true)
        request.sortDescriptors = [sort]
        
        do {
            let typeArray = try viewContext.fetch(request)
            groupedTypeArray = Dictionary(
                    grouping: typeArray,
                    by: { $0.family ?? "" })
        }catch {
            print("DEBUG: Some error occured while fetching")
        }
    }
    
    func deleteType(_ typeToDelete: AircraftType) {
        viewContext.delete(typeToDelete)
        save()
    }
    
    func toggleLocked(_ typeToToggle: AircraftType) {
        typeToToggle.isLocked.toggle()
        save()
    }
    
    
    private func save() {
        do {
            try viewContext.save()
            fetchTypeData()
        }catch {
            print("Error saving")
        }
    }
    
    
    
    
    func addRandomTypes() {
        
        let newType = AircraftType(context: viewContext)
        newType.name = "A321"
        newType.family = "A320"
        newType.maker = "Airbus"
        newType.efis = false
        newType.complex = false
        newType.isLocked = false
        
        let newType2 = AircraftType(context: viewContext)
        newType2.name = "A319"
        newType2.family = "A320"
        newType2.maker = "Airbus"
        newType2.efis = true
        newType2.complex = true
        newType2.isLocked = false
        
        let newType3 = AircraftType(context: viewContext)
        newType3.name = "B788"
        newType3.family = "B787"
        newType3.maker = "Boeing"
        newType3.efis = true
        newType3.highPerformance = true
        newType3.complex = true
        newType3.isLocked = false
        
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
        
        save()
    }
}
