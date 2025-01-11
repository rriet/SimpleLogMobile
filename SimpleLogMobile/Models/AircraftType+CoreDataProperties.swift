//
//  AircraftType+CoreDataProperties.swift
//  SimpleLog
//
//  Created by Ricardo Brito Riet Correa on 1/10/25.
//
//

import Foundation
import CoreData


extension AircraftType {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AircraftType> {
        return NSFetchRequest<AircraftType>(entityName: "AircraftType")
    }

    @NSManaged public var categoryString: String?
    @NSManaged public var complex: Bool
    @NSManaged public var efis: Bool
    @NSManaged public var engineType: String?
    @NSManaged public var family: String?
    @NSManaged public var highPerformance: Bool
    @NSManaged public var isLocked: Bool
    @NSManaged public var maker: String?
    @NSManaged public var mtow: Int64
    @NSManaged public var multiEngine: Bool
    @NSManaged public var multiPilot: Bool
    @NSManaged public var name: String?

}

extension AircraftType : Identifiable {

}
