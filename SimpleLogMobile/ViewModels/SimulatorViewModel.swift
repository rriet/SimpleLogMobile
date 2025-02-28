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
            
            updateCrew(newSimualtorTraining, crew: crew)
            
            try viewContext.save()
    }
    
    private func updateCrew(_ simulatorTraining: SimulatorTraining, crew: [Crew: CrewPosition]) {
        let currentCrew = simulatorTraining.flightCrews as? Set<FlightCrew> ?? []

        if crew.isEmpty {
            // Remove all crew assignments
            currentCrew.forEach { viewContext.delete($0) }
        } else {
            // Update existing and add new crew members
            crew.forEach { (crewMember, position) in
                if let existingAssignment = currentCrew.first(where: { $0.crew == crewMember }) {
                    existingAssignment.position = position
                } else {
                    let newAssignment = FlightCrew(context: viewContext)
                    newAssignment.simulatorTraining = simulatorTraining
                    newAssignment.crew = crewMember
                    newAssignment.position = position
                }
            }
        }
    }
}
