//
//  Airport+CoreDataClass.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/19/25.
//
//

import Foundation
import CoreData

@objc(Airport)
public class Airport: NSManagedObject, SwipeableItem, Comparable {

    public static func < (lhs: Airport, rhs: Airport) -> Bool {
        lhs.icao ?? "" < rhs.icao ?? ""
    }
    
    var allowDelete: Bool {
        !self.isLocked && !self.hasFlights
    }
    
    var hasFlights: Bool {
        !self.flightsArray.isEmpty
    }
    
    var flightsDepartingArray: [Flight] {
        let flts = self.flightsDeparting as? Set<Flight> ?? []
        return flts.sorted()
    }
    
    var flightsArrivingArray: [Flight] {
        let flts = self.flightsArriving as? Set<Flight> ?? []
        return flts.sorted()
    }
    
    var flightsArray: [Flight] {
        return (flightsDepartingArray + flightsArrivingArray).sorted()
    }
    
    var hasPositioning: Bool {
        !self.positioningArray.isEmpty
    }
    
    var positioningDepartingArray: [Positioning] {
        let positioningDeparting = self.positioningDeparting as? Set<Positioning> ?? []
        return positioningDeparting.sorted ()
    }
    
    var positioningArrivingArray: [Positioning] {
        let positioningArriving = self.positioningArriving as? Set<Positioning> ?? []
        return positioningArriving.sorted ()
    }
    
    var positioningArray: [Positioning] {
        return (positioningArrivingArray + positioningArrivingArray).sorted()
    }
    
    var toString: String {
        "\(self.icao ?? "")\(self.iata != nil && !self.iata!.isEmpty ? "/\(self.iata!)" : "") \(self.name ?? "")"
    }
}
