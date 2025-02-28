//
//  Crew+CoreDataClass.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/17/25.
//
//

import Foundation
import CoreData

@objc(Crew)
public class Crew: NSManagedObject, SwipeableItem, Comparable {

    public static func < (lhs: Crew, rhs: Crew) -> Bool {
        lhs.name ?? "" < rhs.name ?? ""
    }
    
    var allowDelete: Bool {
        !self.isLocked && !hasFlights && !hasSimTrainingArray
    }
    
    var hasFlights: Bool {
        !self.flightsArray.isEmpty
    }
    
    var flightsArray: [Flight] {
        let flightCrewSet = self.flightCrews as? Set<FlightCrew> ?? []
        let flights = flightCrewSet.compactMap { $0.flight }
        return flights.sorted()
    }
    
    var hasSimTrainingArray: Bool {
        !self.simTrainingArray.isEmpty
    }
    
    var simTrainingArray: [SimulatorTraining] {
        let flightCrewSet = self.flightCrews as? Set<FlightCrew> ?? []
        let sims = flightCrewSet.compactMap { $0.simulatorTraining }
        return sims.sorted()
    }
    
    var initials:String {
        let words = self.name.strUnwrap.split(separator: " ")
        let initials = words.prefix(2).compactMap { $0.first }.map { String($0) }
        return initials.joined().uppercased()
    }
}
