//
//  FlightViewModel.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/23/25.
//

import Foundation
import CoreData

class FlightViewModel: ObservableObject {
    
    let defaults = UserDefaults.standard
    
    private let viewContext = PersistenceController.shared.viewContext
    
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
