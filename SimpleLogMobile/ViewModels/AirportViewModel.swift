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
    
    init() {
        try? fetchAirportList()
    }
    
    func fetchAirportList() throws {
        let request = Airport.fetchRequest()
        let sort = NSSortDescriptor(key: "icao", ascending: true)
        request.sortDescriptors = [sort]
        
        do {
            airportList = try viewContext.fetch(request)
        }catch {
            throw ErrorDetails(
                title: "Error!",
                message: "Unknown error fetching crew.")
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
        isLocked: Bool = false
    ) throws {
        let newAirport = Airport(context: viewContext)
        
        try editAirport(newAirport,
                         icao: icao,
                         iata: iata,
                         name: name,
                         city: city,
                         country: country,
                         latitude: latitude,
                         longitude: longitude,
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
                         isLocked: Bool = false
    ) throws {
        
        if icao.trimmingCharacters(in: .whitespaces).count < 1 {
            throw ErrorDetails(
                title: "Invalid ICAO",
                message: "ICAO code must be at least 1 characters long.")
        }
        
        airportToEdit.icao = icao.trimmingCharacters(in: .whitespaces)
        airportToEdit.iata = iata.trimmingCharacters(in: .whitespaces)
        airportToEdit.name = name.trimmingCharacters(in: .whitespaces)
        airportToEdit.city = city.trimmingCharacters(in: .whitespaces)
        airportToEdit.country = country.trimmingCharacters(in: .whitespaces)
        airportToEdit.latitude = latitude
        airportToEdit.longitude = longitude
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
        
        viewContext.delete(airportToDelete)
        try save()
    }
    
    func toggleLocked(_ airportToToggle: Airport) throws {
        airportToToggle.isLocked.toggle()
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
        try fetchAirportList()
    }
}
