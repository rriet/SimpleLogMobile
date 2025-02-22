//
//  SimulatorViewModel.swift
//  SimpleLogMobile
//
//  Created by Ricardo Riet Correa on 21/02/2025.
//

import Foundation
import CoreData

class SimulatorViewModel: ObservableObject {
    
    private let defaults = UserDefaults.standard
    private let viewContext = PersistenceController.shared.viewContext
    
    func addSimulatorTraining(
            startDate: Date,
            endDate: Date,
            aircraft: Aircraft,
            remarks: String,
            notes: String,
            timeSession: Int,
            crew: [Crew: CrewPosition],
            endorsementSignature: Data?
    ) throws -> SimulatorTraining {
            
        let newSimualtorTraining = SimulatorTraining(context: viewContext)
        newSimualtorTraining.startTimeline = Timeline(context: viewContext)
        
        try editSimulatorTraining(
            newSimualtorTraining: newSimualtorTraining,
            startDate: startDate,
            endDate: endDate,
            aircraft: aircraft,
            remarks: remarks,
            notes: notes,
            timeSession: timeSession,
            crew: crew,
            endorsementSignature: endorsementSignature
        )
    
        return newSimualtorTraining
    }
    
    func editSimulatorTraining(
            newSimualtorTraining: SimulatorTraining,
            startDate: Date,
            endDate: Date,
            aircraft: Aircraft,
            remarks: String,
            notes: String,
            timeSession: Int,
            crew: [Crew: CrewPosition],
            endorsementSignature: Data?
        ) throws {
            
            newSimualtorTraining.startTimeline?.dateValue = startDate
            newSimualtorTraining.dateEnd = endDate
            newSimualtorTraining.aircraft = aircraft
            newSimualtorTraining.remarks = remarks
            newSimualtorTraining.notes = notes
            newSimualtorTraining.timeSession = Int16(timeSession)
            newSimualtorTraining.endorsementSignature = endorsementSignature
            
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
