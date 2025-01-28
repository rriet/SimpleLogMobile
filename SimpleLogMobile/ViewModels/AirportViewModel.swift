//
//  AirportViewModel.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/19/25.
//

import Foundation
import CoreData

class AirportViewModel: ObservableObject {
    
    private let viewContext = PersistenceController.shared.viewContext
    @Published var airportList: [Airport] = []
    private var batchSize = 20 // Number of airports to fetch per batch
    private var isFetching = false // Prevent multiple fetches at once
    
    init() {
        try? fetchAirportList()
    }
    
    func fetchAirportList(offset: Int = 0, searchText: String = "", refresh: Bool = false) throws {
        guard !isFetching else { return }
        isFetching = true
        
        let request = Airport.fetchRequest()
        let sortStar = NSSortDescriptor(key: "isFavorite", ascending: false)
        let sortIcao = NSSortDescriptor(key: "icao", ascending: true)
        request.sortDescriptors = [sortStar, sortIcao]
        request.fetchLimit = batchSize
        request.fetchOffset = offset
        
        if !searchText.isEmpty {
            let predicate = NSPredicate(format: "(icao CONTAINS[cd] %@) OR (iata CONTAINS[cd] %@) OR (name CONTAINS[cd] %@) OR (city CONTAINS[cd] %@) OR (country CONTAINS[cd] %@)", searchText, searchText, searchText, searchText, searchText)
            request.predicate = predicate
        }
        
        let newAirports = try viewContext.fetch(request)
        DispatchQueue.main.async {
            if refresh {
                self.airportList = newAirports
            } else {
                self.airportList.append(contentsOf: newAirports)
            }
            
            self.isFetching = false
        }
    }
    
    func addAirport(
        icao: String,
        iata: String = "",
        name: String = "",
        city: String = "",
        country: String = "",
        latitude: Double = 0,
        longitude: Double = 0,
        isFavorite: Bool = false
    ) throws {
        let newAirport = Airport(context: viewContext)
        
        let isLocked = AppSettings.autoLockNewEntries
        
        try editAirport(newAirport,
                         icao: icao,
                         iata: iata,
                         name: name,
                         city: city,
                         country: country,
                         latitude: latitude,
                         longitude: longitude,
                         isFavorite: isFavorite,
                         isLocked: isLocked)
    }
    
    func editAirport(_ airportToEdit: Airport,
                         icao: String,
                         iata: String = "",
                         name: String = "",
                         city: String = "",
                         country: String = "",
                         latitude: Double = 0,
                         longitude: Double = 0,
                         isFavorite: Bool = false,
                         isLocked: Bool = false
    ) throws {
        
        if icao.trimmingCharacters(in: .whitespaces).count < 1 {
            throw ErrorDetails(
                title: "Invalid ICAO",
                message: "ICAO code must be at least 1 characters long.")
        }
        
        airportToEdit.icao = icao.uppercased().trimmingCharacters(in: .whitespaces)
        airportToEdit.iata = iata.uppercased().trimmingCharacters(in: .whitespaces)
        airportToEdit.name = name.trimmingCharacters(in: .whitespaces).lowercased().capitalized
        airportToEdit.city = city.trimmingCharacters(in: .whitespaces).lowercased().capitalized
        airportToEdit.country = country.trimmingCharacters(in: .whitespaces).lowercased().capitalized
        airportToEdit.latitude = latitude
        airportToEdit.longitude = longitude
        airportToEdit.isFavorite = isFavorite
        airportToEdit.isLocked = isLocked
        
        try save()
    }
    
    func checkExist(_ icao: String) throws -> Bool {
        let request = Airport.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "icao ==[c] %@", icao)
        
        do {
            let count = try viewContext.count(for: request)
            return count > 0
        } catch {
            throw ErrorDetails(
                title: "Error!",
                message: "There was an unknown error reading from database.")
        }
    }
    
    func deleteAirport(_ airportToDelete: Airport) throws {
        guard !airportToDelete.isLocked else {
            throw ErrorDetails(
                title: "Airport Locked",
                message: "The selected Airport cannot be deleted because it is locked.")
        }
        
        guard !airportToDelete.hasFlights else {
            throw ErrorDetails(
                title: "Cannot Delete Airport",
                message: "The selected Airport cannot be deleted because it is associated with one or more Flight.")
        }
        
        guard !airportToDelete.hasPositioning else {
            throw ErrorDetails(
                title: "Cannot Delete Airport",
                message: "The selected Airport cannot be deleted because it is associated with one or more Positioning trip.")
        }
        
        // remove the airport from the list
        if let index = airportList.firstIndex(where: { $0.id == airportToDelete.id }) {
            airportList.remove(at: index)
        }
        
        // delete from database
        viewContext.delete(airportToDelete)
        try save()
    }
    
    func toggleLocked(_ airportToToggle: Airport) throws {
        airportToToggle.isLocked.toggle()
        try save()
    }
    
    func toggleFavorite(_ airportToToggle: Airport) throws {
        airportToToggle.isFavorite.toggle()
        
        // reorder display array
        airportList = airportList.sorted {
            // First, compare by isFavorite (true first)
            if $0.isFavorite != $1.isFavorite {
                return $0.isFavorite && !$1.isFavorite
            }
            
            // If isFavorite is the same, then compare by icao
            return $0.icao ?? "" < $1.icao ?? ""
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
        objectWillChange.send()
    }
}
