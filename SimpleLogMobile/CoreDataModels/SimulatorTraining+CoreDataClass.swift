//
//  SimulatorTraining+CoreDataClass.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/16/25.
//
//

import Foundation
import CoreData

@objc(SimulatorTraining)
public class SimulatorTraining: NSManagedObject, SwipeableItem, Comparable {
    public static func < (lhs: SimulatorTraining, rhs: SimulatorTraining) -> Bool {
        guard let lhsDate = lhs.startTimeline else { return false }
        guard let rhsDate = rhs.startTimeline else { return true }
        return lhsDate.dateValue ?? .now < rhsDate.dateValue ?? .now
    }
    
    var allowDelete: Bool {
        !self.isLocked
    }
}
