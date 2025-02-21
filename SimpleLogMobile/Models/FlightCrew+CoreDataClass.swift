//
//  FlightCrew+CoreDataClass.swift
//  SimpleLogMobile
//
//  Created by Ricardo Riet Correa on 14/02/2025.
//
//

import Foundation
import CoreData

@objc(FlightCrew)
public class FlightCrew: NSManagedObject {

    var position: CrewPosition {
        get {
            CrewPosition(rawValue: positionString.strUnwrap) ?? .PIC
        }
        set {
            positionString = newValue.rawValue
        }
    }
}

enum CrewPosition: String, Codable, CaseIterable {
    case PIC = "PIC"
    case SIC = "SIC"
    case Instructor = "Instructor"
    case Observer = "Observer"
    case Relief = "Relief Pilot"
    case ReliefCaptain = "Relief Captain"
    case ReliefFirstOfficer = "Relief First Officer"
    case CabinSenior = "Cabin Senior"
    case CabinCrew = "Cabin Crew"
    case Other = "Other"
}
