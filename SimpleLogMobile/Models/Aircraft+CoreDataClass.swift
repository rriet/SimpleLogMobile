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
public class Aircraft: NSManagedObject, SwipeableItem {

    var allowDelete: Bool {
        true
    }
}
