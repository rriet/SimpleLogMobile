//
//  Positioning+CoreDataClass.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/19/25.
//
//

import Foundation
import CoreData

@objc(Positioning)
public class Positioning: NSManagedObject, SwipeableItem, Comparable {
    
    public static func < (lhs: Positioning, rhs: Positioning) -> Bool {
        guard let lhsDate = lhs.positioningStart else { return false }
        guard let rhsDate = rhs.positioningStart else { return true }
        return lhsDate.dateValue ?? .now < rhsDate.dateValue ?? .now
    }
    
    var allowDelete: Bool {
        !self.isLocked
    }
}
