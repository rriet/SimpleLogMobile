//
//  AircraftType+CoreDataClass.swift
//  SimpleLog
//
//  Created by Ricardo Brito Riet Correa on 1/10/25.
//
//

import Foundation
import CoreData

@objc(AircraftType)
public class AircraftType: NSManagedObject, SwipeableItem {
    
    var allowDelete: Bool {
        true
    }
    
    /// Indicates whether the Type has any associated Aircraft.
    /// - Returns: `true` if the Type has one or more Aircraft; otherwise, `false`.
    var hasAircraft: Bool {
        //        !aircrafts.isEmpty
        false
    }
    
    /// Returns a list of `AircraftModel` instances associated with this aircraft type.
    /// - If no relationships are set, returns an empty array.
    //    var aircrafts: [AircraftModel] {
    //        aircraftsRelationship ?? []
    //    }
    
    var category: AircraftCategory {
        get {
            AircraftCategory(rawValue: categoryString ?? "Landplane") ?? .Landplane
        }
        set {
            categoryString = newValue.rawValue
        }
    }
}

/// Enum representing different aircraft classes (e.g., amphibian, landplane, helicopter).
/// Each case corresponds to a specific type of aircraft with distinct characteristics.
enum AircraftCategory: String, Codable, CaseIterable {
    case Amphibian = "Amphibian"
    case Gyrocopter = "Gyrocopter"
    case Helicopter = "Helicopter"
    case Landplane = "Landplane"
    case Seaplane = "Seaplane"
    case Tiltwing = "Tilt-wing"
}

/// Enum representing various engine types used in aircraft (e.g., Jet, Piston, Turboprop).
/// These engine types help categorize the aircraft's propulsion system.
enum EngineTypes: String, Codable, CaseIterable {
    case Rocket = "Rocket"
    case Piston = "Piston"
    case Turboprop = "Turboprop/Turboshaft"
    case Jet = "Jet"
    case Electric = "Electric"
    case UltraLightAircraft = "Ultra-light Aircraft"
    case Drone = "Drone"
    case Helicopter = "Helicopter"
    case UltraLightGyrocopter = "Micro-/Ultra-light Gyrocopter"
    case UltraLightHelicopter = "Ultra-light Helicopter"
    case Glider = "Glider/Sailplane"
    case Airship = "Airship"
    case Balloon = "Balloon"
    case ZZZZ = "Aircraft type not yet assigned"
    case Paraplane = "Powered parachute/Paraplane."
}
