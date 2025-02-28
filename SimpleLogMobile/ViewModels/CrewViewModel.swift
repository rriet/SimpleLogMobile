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
    private var batchSize = 20
    
    func fetchCrewList(offset: Int = 0, searchText: String = "", refresh: Bool = false) throws {
        let request = Crew.fetchRequest()
        let sortStar = NSSortDescriptor(key: "isFavorite", ascending: false)
        let sortName = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortStar, sortName]
        request.fetchLimit = batchSize
        request.fetchOffset = offset
        
        if !searchText.isEmpty {
            request.predicate = NSPredicate(
                format: "(name CONTAINS[cd] %@) OR (phone CONTAINS[cd] %@) OR (email CONTAINS[cd] %@) OR (notes CONTAINS[cd] %@)",
                searchText, searchText, searchText, searchText)
        }
        
        let newCrewList = try viewContext.fetch(request)
        DispatchQueue.main.async {
            if refresh {
                self.crewList = newCrewList
            } else {
                self.crewList.append(contentsOf: newCrewList)
            }
        }
    }
    
    func addCrew(
        name: String = "",
        email: String = "",
        phone: String = "",
        notes: String = "",
        picture: Data? = nil,
        isFavorite: Bool = false
    ) throws -> Crew {
        let newCrew = Crew(context: viewContext)
        
        try editCrew(newCrew,
                     name: name,
                     email: email,
                     phone: phone,
                     notes: notes,
                     picture: picture,
                     isLocked: AppSettings.autoLockNewEntries,
                     isFavorite: isFavorite)
        
        return newCrew
    }
    
    func editCrew(_ crewToEdit: Crew,
                  name: String = "",
                  email: String = "",
                  phone: String = "",
                  notes: String = "",
                  picture: Data? = nil,
                  isLocked: Bool = false,
                  isFavorite: Bool = false
    ) throws {
        
        if name.count < 1 {
            throw ErrorDetails(
                title: "Invalid Name",
                message: "Crew Name must be at least 1 characters long.")
        }
        
        crewToEdit.name = name.trimmingCharacters(in: .whitespaces)
        crewToEdit.email = email.trimmingCharacters(in: .whitespaces)
        crewToEdit.phone = phone.trimmingCharacters(in: .whitespaces)
        crewToEdit.notes = notes
        crewToEdit.picture = picture
        crewToEdit.isLocked = isLocked
        crewToEdit.isFavorite = isFavorite
        
        try viewContext.save()
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
    
    func hasSelf() throws -> Bool {
        let request = Crew.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "isSelf == %@", NSNumber(value: false))
        
        do {
            let count = try viewContext.count(for: request)
            return count > 0
        } catch {
            throw ErrorDetails(
                title: "Error!",
                message: "There was an unknown error reading from database.")
        }
    }
    
    func getCrew(_ name: String) throws -> Crew? {
        let request = Crew.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "name ==[c] %@", name)

        do {
            let result = try viewContext.fetch(request)
            return result.first // Return the first matched aircraft
        } catch {
            throw ErrorDetails(
                title: "Error!",
                message: "There was an unknown error reading from the database.")
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
        try viewContext.save()
    }
    
    func toggleLocked(_ crewToToggle: Crew) throws {
        crewToToggle.isLocked.toggle()
        try viewContext.save()
    }
    
    func toggleFavorite(_ crewToToggle: Crew) throws {
        crewToToggle.isFavorite.toggle()
        
        // reorder display array
        crewList = crewList.sorted {
            // First, compare by isFavorite (true first)
            if $0.isFavorite != $1.isFavorite {
                return $0.isFavorite && !$1.isFavorite
            }
            
            // If isFavorite is the same, then compare by icao
            return $0.name ?? "" < $1.name ?? ""
        }
        
        try viewContext.save()
    }
}
