//
//  PreviousExperience+CoreDataClass.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/19/25.
//
//

import Foundation
import CoreData

@objc(PreviousExperience)
public class PreviousExperience: NSManagedObject, SwipeableItem {
    
    var allowDelete: Bool {
        !self.isLocked
    }
}
