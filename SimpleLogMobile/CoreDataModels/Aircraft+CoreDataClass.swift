//
//  Aircraft+CoreDataClass.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/11/25.
//
//

import Foundation
import CoreData

@objc(Aircraft)
public class Aircraft: NSManagedObject, SwipeableItem, Comparable {
    
    public static func < (lhs: Aircraft, rhs: Aircraft) -> Bool {
        lhs.registration ?? "" < rhs.registration ?? ""
    }

    var allowDelete: Bool {
        !self.isLocked && !hasFlights && !hasSimTrainingArray
    }
    
    var mtowString: String {
        if self.aircraftMtow == 0 {
            return formatNumericValue(self.aircraftType?.mtow ?? 0)
        } else {
            return formatNumericValue(self.aircraftMtow)
        }
    }
    
    var hasFlights: Bool {
        !self.flightsArray.isEmpty
    }
    
    var flightsArray: [Flight] {
        let flts = self.flights as? Set<Flight> ?? []
        return flts.sorted()
    }
    
    var hasSimTrainingArray: Bool {
        !self.simTrainingArray.isEmpty
    }
    
    var simTrainingArray: [SimulatorTraining] {
        let sims = self.simTrainings as? Set<SimulatorTraining> ?? []
        return sims.sorted ()
    }
}
