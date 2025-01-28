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
    
    init() {
        try? fetchAircraftList()
    }
    
    func fetchAircraftList() throws {
        let request = Aircraft.fetchRequest()
        let sort = NSSortDescriptor(key: "registration", ascending: true)
        request.sortDescriptors = [sort]
        
        do {
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
        isSimulator: Bool
    ) throws {
        let newAircraft = Aircraft(context: viewContext)
        
        let isLocked = AppSettings.autoLockNewEntries
        
        try editAircraft(
            aircraftToEdit: newAircraft,
            registration: registration,
            aircraftMtow: aircraftMtow,
            aircraftType: aircraftType,
            isSimulator: isSimulator,
            isLocked: isLocked
        )
    }
    
    func editAircraft(
        aircraftToEdit: Aircraft,
        registration: String,
        aircraftMtow: String,
        aircraftType: AircraftType,
        isSimulator: Bool,
        isLocked: Bool = false
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
    
    private func save() throws {
        do {
            try viewContext.save()
        } catch {
            throw ErrorDetails(
                title: "Error!",
                message: "There was an unknown error saving to database.")
        }
        try fetchAircraftList()
    }
}
