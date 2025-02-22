//
//  Timeline+CoreDataClass.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/19/25.
//
//

import Foundation
import CoreData

@objc(Timeline)
public class Timeline: NSManagedObject, Comparable {
    
    public static func < (lhs: Timeline, rhs: Timeline) -> Bool {
        return lhs.dateValue ?? .now < lhs.dateValue ?? .now
    }
    
    var getDate: Date {
        dateValue ?? .now
    }
    
    var hasFlight: Bool {
        self.flightStart != nil
    }
    
    var flight: Flight {
        return self.flightStart!
    }
    
    var hasSimulatorTraining: Bool {
        self.simulatorStart != nil
    }
    
    var simulatorTraining: SimulatorTraining {
        self.simulatorStart!
    }
}
