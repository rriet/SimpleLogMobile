//
//  DutyPeriod+CoreDataClass.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/19/25.
//
//

import Foundation
import CoreData

@objc(DutyPeriod)
public class DutyPeriod: NSManagedObject, SwipeableItem, Comparable {

    public static func < (lhs: DutyPeriod, rhs: DutyPeriod) -> Bool {
        guard let lhsDate = lhs.dutyStart else { return false }
        guard let rhsDate = rhs.dutyStart else { return true }
        return lhsDate.dateValue ?? .now < rhsDate.dateValue ?? .now
    }
    
    var allowDelete: Bool {
        !self.isLocked
    }
}
