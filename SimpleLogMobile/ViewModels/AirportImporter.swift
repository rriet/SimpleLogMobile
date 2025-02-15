//
//  AirportImporter.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/26/25.
//

import Foundation

func AirportImporter() throws {
    
    let airportVM = AirportViewModel()
    
    if let fileURL = Bundle.main.url(forResource: "airports", withExtension: "csv") {
    
    // Parse the CSV file
    let rows = try parseCSV(from: fileURL)
    
    // Skip the header row and process each row
        for row in rows.dropFirst() { // Skip the first row (headers)
            if row.count < 7 { continue } // Ensure row has all columns
            
            // Extract values
            let icao = row[0]
            let iata = row[1]
            let name = row[2]
            let city = row[3]
            let country = row[4]
            let latitude = Double(row[5]) ?? 0.0
            let longitude = Double(row[6]) ?? 0.0
            
            try _ = airportVM.addAirport(
                icao: icao,
                iata: iata,
                name: name,
                city: city,
                country: country,
                latitude: latitude,
                longitude: longitude
            )
        }
    }
}
