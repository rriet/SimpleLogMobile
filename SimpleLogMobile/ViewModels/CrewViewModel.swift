//
//  CrewViewModel.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/17/25.
//

import Foundation
import CoreData

class CrewViewModel: ObservableObject {
    private let viewContext = PersistenceController.shared.viewContext
    @Published var crewList: [Crew] = []
    
    init() {
        try? fetchCrewList()
    }
    
    func fetchCrewList() throws {
        let request = Crew.fetchRequest()
        let sort = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sort]
        
        do {
            crewList = try viewContext.fetch(request)
        }catch {
            throw ErrorDetails(
                title: "Error!",
                message: "Unknown error fetching crew.")
        }
    }
    
    func addCrew(
        name: String = "",
        email: String = "",
        phone: String = "",
        notes: String = "",
        picture: Data? = nil,
        isLocked: Bool = false
    ) throws {
        let newCrew = Crew(context: viewContext)
        
        try editCrew(newCrew,
                     name: name,
                     email: email,
                     phone: phone,
                     notes: notes,
                     picture: picture,
                     isLocked: isLocked)
    }
    
    func editCrew(_ crewToEdit: Crew,
                  name: String = "",
                  email: String = "",
                  phone: String = "",
                  notes: String = "",
                  picture: Data? = nil,
                  isLocked: Bool = false
    ) throws {
        
        if name.count < 3 {
            throw ErrorDetails(
                title: "Invalid Name",
                message: "Crew Name must be at least 3 characters long.")
        }
        
        crewToEdit.name = name.trimmingCharacters(in: .whitespaces)
        crewToEdit.email = email.trimmingCharacters(in: .whitespaces)
        crewToEdit.phone = phone.trimmingCharacters(in: .whitespaces)
        crewToEdit.notes = notes
        crewToEdit.picture = picture
        crewToEdit.isLocked = isLocked
        
        try save()
    }
    
    func checkExist(_ name: String) throws -> Bool {
        let request = Crew.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "name ==[c] %@", name)
        
        do {
            let count = try viewContext.count(for: request)
            return count > 0
        } catch {
            throw ErrorDetails(
                title: "Error!",
                message: "There was an unknown error reading from database.")
        }
    }
    
    func deleteCrew(_ crewToDelete: Crew) throws {
        guard !crewToDelete.isLocked else {
            throw ErrorDetails(
                title: "Crew Locked",
                message: "The selected Crew cannot be deleted because it is locked.")
        }
        
        guard !crewToDelete.hasFlights else {
            throw ErrorDetails(
                title: "Cannot Delete Crew",
                message: "The selected Crew cannot be deleted because it is associated with one or more Aircraft.")
        }
        
        guard !crewToDelete.hasSimTrainingArray else {
            throw ErrorDetails(
                title: "Cannot Delete Crew",
                message: "The selected Crew cannot be deleted because it is associated with one or more Simulator Training.")
        }
        
        viewContext.delete(crewToDelete)
        try save()
    }
    
    func toggleLocked(_ crewToToggle: Crew) throws {
        crewToToggle.isLocked.toggle()
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
        try fetchCrewList()
    }
}
