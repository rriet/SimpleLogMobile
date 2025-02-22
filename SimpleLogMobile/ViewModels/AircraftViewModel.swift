//
//  AircraftViewModel.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/16/25.
//

import Foundation
import CoreData

class AircraftViewModel: ObservableObject {
    
    private let viewContext = PersistenceController.shared.viewContext
    @Published var aircraftList: [Aircraft] = []
    
    enum SearchType {
        case all
        case aircraft
        case simulator
    }
    
    func fetchAircraftList(searchType: SearchType = .all, searchString: String = "", includeType: Bool = false) throws {
        let request = Aircraft.fetchRequest()
        let sortStar = NSSortDescriptor(key: "isFavorite", ascending: false)
        let sortRegistration = NSSortDescriptor(key: "registration", ascending: true)
        request.sortDescriptors = [sortStar, sortRegistration]
        
        var predicates: [NSPredicate] = []
        switch searchType {
        case .all:
            break // No filtering needed
        case .aircraft:
            predicates.append(NSPredicate(format: "isSimulator == %@", NSNumber(value: false)))
        case .simulator:
            predicates.append(NSPredicate(format: "isSimulator == %@", NSNumber(value: true)))
        }
            
            // Filter by registration search string (if provided)
        if !searchString.isEmpty {
            if includeType {
                predicates.append(NSPredicate(format: "(registration CONTAINS[cd] %@) OR (aircraftType.designator CONTAINS[cd] %@)", searchString, searchString))
            } else {
                predicates.append(NSPredicate(format: "registration CONTAINS[cd] %@", searchString))
            }
        }
        
        do {
            if !predicates.isEmpty {
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            }
            aircraftList = try viewContext.fetch(request)
        }catch {
            throw ErrorDetails(
                title: "Error!",
                message: "Unknown error fetching aircrafts.")
        }
    }
    
    func addAircraft(
        registration: String,
        aircraftMtow: String,
        aircraftType: AircraftType,
        isSimulator: Bool,
        isFavorite: Bool = false
    ) throws -> Aircraft {
        
        let newAircraft = Aircraft(context: viewContext)
        
        let isLocked = AppSettings.autoLockNewEntries
        
        try editAircraft(
            aircraftToEdit: newAircraft,
            registration: registration,
            aircraftMtow: aircraftMtow,
            aircraftType: aircraftType,
            isSimulator: isSimulator,
            isLocked: isLocked,
            isFavorite: isFavorite
        )
        return newAircraft
    }
    
    func editAircraft(
        aircraftToEdit: Aircraft,
        registration: String,
        aircraftMtow: String,
        aircraftType: AircraftType,
        isSimulator: Bool,
        isLocked: Bool = false,
        isFavorite: Bool = false
    ) throws {
        
        if registration.count < 3 {
            throw ErrorDetails(
                title: "Invalid Registration",
                message: "Registration must be at least 3 characters long.")
        }
        
        aircraftToEdit.registration = registration.uppercased().trimmingCharacters(in: .whitespaces)
        aircraftToEdit.aircraftMtow = Int64(aircraftMtow) ?? 0
        aircraftToEdit.aircraftType = aircraftType
        aircraftToEdit.isSimulator = isSimulator
        aircraftToEdit.isLocked = isLocked
        aircraftToEdit.isFavorite = isFavorite
        
        try save()
    }
    
    func checkExist(_ registration: String) throws -> Bool {
        let request = Aircraft.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "registration ==[c] %@", registration)
        
        do {
            let count = try viewContext.count(for: request)
            return count > 0
        } catch {
            throw ErrorDetails(
                title: "Error!",
                message: "There was an unknown error reading from database.")
        }
    }
    
    func getAircraft(_ registration: String) throws -> Aircraft? {
        let request = Aircraft.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "registration ==[c] %@", registration)

        do {
            let result = try viewContext.fetch(request)
            return result.first // Return the first matched aircraft
        } catch {
            throw ErrorDetails(
                title: "Error!",
                message: "There was an unknown error reading from the database.")
        }
    }
    
    func deleteAircraft(_ aircraftToDelete: Aircraft) throws {
        
        guard !aircraftToDelete.isLocked else {
            throw ErrorDetails(
                title: "Aircraft Locked",
                message: "The selected Aircraft cannot be deleted because it is locked.")
        }
        
        guard !aircraftToDelete.hasFlights else {
            throw ErrorDetails(
                title: "Cannot Delete Aircraft",
                message: "The selected Aircraft cannot be deleted because it is associated with one or more Aircraft.")
        }
        
        guard !aircraftToDelete.hasSimTrainingArray else {
            throw ErrorDetails(
                title: "Cannot Delete Aircraft",
                message: "The selected Aircraft cannot be deleted because it is associated with one or more Simulator Training.")
        }
        
        viewContext.delete(aircraftToDelete)
        try save()
    }
    
    func toggleLocked(_ typeToToggle: Aircraft) throws {
        typeToToggle.isLocked.toggle()
        try save()
    }
    
    func toggleFavorite(_ aircraftToToggle: Aircraft) throws {
        aircraftToToggle.isFavorite.toggle()
        
        // reorder display array
        aircraftList = aircraftList.sorted {
            // First, compare by isFavorite (true first)
            if $0.isFavorite != $1.isFavorite {
                return $0.isFavorite && !$1.isFavorite
            }
            
            // If isFavorite is the same, then compare by icao
            return $0.registration ?? "" < $1.registration ?? ""
        }
        
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
    }
}
