//
//  AirportImporter.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/26/25.
//

import Foundation

// Define a Codable struct for decoding the JSON data
//struct AirportImport: Codable {
//    let icao: String
//    let iata: String
//    let name: String
//    let city: String
//    let country: String
//    let latitude: String
//    let longitude: String
//}

func importAirports() throws {
    
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
            
            try airportVM.addAirport(
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

func parseCSV(from fileURL: URL) throws -> [[String]] {
    // Read the CSV file as a string
    let content = try String(contentsOf: fileURL)
    
    // Split the content into rows (lines)
    let rows = content.components(separatedBy: "\n").filter { !$0.isEmpty }
    
    let parsedData = rows.map { row in
        // Remove surrounding quotes from each field and split by commas
        row.split(separator: ",").map { field in
            field.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
        }
    }
    
    // Parse each row into columns, considering commas as separators
//    let parsedData2 = rows.map { $0.components(separatedBy: ",") }
    
    return parsedData
}
