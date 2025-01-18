//
//  TypeViewModel.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/11/25.
//

import Foundation
import CoreData

class AircraftTypeViewModel: ObservableObject {
    
    private let viewContext = PersistenceController.shared.viewContext
    @Published var typeList: [AircraftType] = []
    
    init() {
        try? fetchTypeList()
    }
    
    func fetchFamilyList() throws -> [String] {
        // Create a fetch request for AircraftType
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "AircraftType")
        request.resultType = .dictionaryResultType
        request.returnsDistinctResults = true
        request.propertiesToFetch = ["family"]
        
        do {
            // Fetch the results as an array of NSDictionary
            let results = try viewContext.fetch(request) as? [NSDictionary]
            
            // Extract the "family" property values
            let families = results?.compactMap { $0["family"] as? String } ?? []
            
            // Return the unique families (ensured by returnsDistinctResults)
            return families
        }catch {
            throw ErrorDetails(
                title: "Error!",
                message: "Unknown error fetching aircraft types.")
        }
    }
    
    func fetchTypeList() throws {
        let request = AircraftType.fetchRequest()
        let sort = NSSortDescriptor(key: "designator", ascending: true)
        request.sortDescriptors = [sort]
        
        do {
            typeList = try viewContext.fetch(request)
        }catch {
            throw ErrorDetails(
                title: "Error!",
                message: "Unknown error fetching aircraft types.")
        }
    }
    
    func addType(
        designator: String,
        family: String,
        maker: String = "",
        aircraftCategory: AircraftCategory = .Landplane,
        engineType: EngineTypes = .Jet,
        mtow: String = "0",
        multiEngine: Bool = true,
        multiPilot: Bool = true,
        efis: Bool = true,
        complex: Bool = true,
        highPerformance: Bool = true,
        isLocked: Bool = false
    ) throws -> AircraftType {
        
        try checkTypeDesignator(designator)
        
        if try checkExist(designator) {
            throw ErrorDetails(
                title: "Duplicated Type",
                message: "This Aircraft Type already exists.")
        }
        
        let newType = AircraftType(context: viewContext)
        
        try editType(
            typeToEdit: newType,
            designator: designator,
            family: family,
            maker: maker,
            aircraftCategory: aircraftCategory,
            engineType: engineType,
            mtow: mtow,
            multiEngine: multiEngine,
            multiPilot: multiPilot,
            efis: efis,
            complex: complex,
            highPerformance: highPerformance,
            isLocked: isLocked
        )
        
        return newType
    }
    
    func editType(
        typeToEdit: AircraftType,
        designator: String,
        family: String,
        maker: String = "",
        aircraftCategory: AircraftCategory = .Landplane,
        engineType: EngineTypes = .Jet,
        mtow: String = "0",
        multiEngine: Bool = true,
        multiPilot: Bool = true,
        efis: Bool = true,
        complex: Bool = true,
        highPerformance: Bool = true,
        isLocked: Bool = false
    ) throws {
        
        try checkTypeDesignator(designator)
        
        typeToEdit.designator = designator.uppercased().trimmingCharacters(in: .whitespaces)
        typeToEdit.family = (family.count > 0) ? family.trimmingCharacters(in: .whitespaces) : designator.trimmingCharacters(in: .whitespaces)
        typeToEdit.maker = maker.trimmingCharacters(in: .whitespaces)
        typeToEdit.category = aircraftCategory
        typeToEdit.engine = engineType
        typeToEdit.mtow = Int64(mtow) ?? 0
        typeToEdit.multiEngine = multiEngine
        typeToEdit.multiPilot = multiPilot
        typeToEdit.efis = efis
        typeToEdit.complex = complex
        typeToEdit.highPerformance = highPerformance
        typeToEdit.isLocked = isLocked
        
        try save()
    }
    
    func checkExist(_ designator: String) throws -> Bool {
        let request = AircraftType.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "designator ==[c] %@", designator)
        
        do {
            let count = try viewContext.count(for: request)
            return count > 0
        } catch {
            throw ErrorDetails(
                title: "Error!",
                message: "There was an unknown error reading from database.")
        }   
    }
    
    func checkTypeDesignator (_ designator: String) throws {
        if designator.count < 3 {
            throw ErrorDetails(
                title: "Invalid Type",
                message: "Type designator must be at least 3 characters long.")
        }
    }
    
    func deleteType(_ typeToDelete: AircraftType) throws {
        
        guard !typeToDelete.isLocked else {
            throw ErrorDetails(
                title: "Aircraft Locked",
                message: "The selected Type cannot be deleted because it is locked.")
        }
        
        guard !typeToDelete.hasAircraft else {
            throw ErrorDetails(
                title: "Cannot Delete Aircraft Type",
                message: "The selected Type cannot be deleted because it is associated with one or more Aircraft.")
        }
        
        viewContext.delete(typeToDelete)
        try save()
    }
    
    func toggleLocked(_ typeToToggle: AircraftType) throws {
        typeToToggle.isLocked.toggle()
        try save()
    }
    
    
    private func save() throws {
        do {
            try viewContext.save()
        } catch {
            throw ErrorDetails(
                title: "Error!",
                message: "There was an unknown error saving to database.")
        }
        try fetchTypeList()
    }
    
    func addRandomTypes() {
        
        let newType = AircraftType(context: viewContext)
        newType.designator = "A321"
        newType.family = "A320"
        newType.maker = "Airbus"
        newType.efis = false
        newType.complex = false
        newType.isLocked = false
        
        let newType2 = AircraftType(context: viewContext)
        newType2.designator = "A319"
        newType2.family = "A320"
        newType2.maker = "Airbus"
        newType2.efis = true
        newType2.complex = true
        newType2.isLocked = false
        
        let newType3 = AircraftType(context: viewContext)
        newType3.designator = "B788"
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
        
        try! save()
    }
}
