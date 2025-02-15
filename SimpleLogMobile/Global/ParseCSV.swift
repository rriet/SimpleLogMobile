//
//  ParseCSV.swift
//  SimpleLogMobile
//
//  Created by Ricardo Riet Correa on 14/02/2025.
//

import Foundation

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
