//
//  Flight+CoreDataClass.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/16/25.
//
//

import Foundation
import CoreData

@objc(Flight)
public class Flight: NSManagedObject, SwipeableItem, Comparable {
    
    public static func < (lhs: Flight, rhs: Flight) -> Bool {
        guard let lhsDate = lhs.startTimeline else { return false }
        guard let rhsDate = rhs.startTimeline else { return true }
        return lhsDate.dateValue ?? .now < rhsDate.dateValue ?? .now
    }
    
    var allowDelete: Bool {
        !self.isLocked
    }
}
