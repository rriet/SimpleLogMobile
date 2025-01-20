//
//  LatitudeExtension.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/19/25.
//

import CoreLocation

extension CLLocationCoordinate2D {
    
    /**
     Converts the coordinate to a readable coordinate in sexagesimal format.
     
     - returns:
     A tuple of two Strings. First string is the formatted latitude coordinate string, second ist the formatted longituted coordinate string.
     */
    func string() -> (lat: String, lon: String) {
        ( self.latitude.stringFromLatitude(), self.longitude.stringFromLongitude() )
    }
}

extension Double {
    func stringFromLatitude() -> String {
        var latitudeString = String(format: "%02d° ", abs(Int(self))) +
        String(format: "%05.2f'", abs(self.truncatingRemainder(dividingBy: 1)) * 60)
        
        // Generate correct cardinal suffix
        if self >= 0 {
            return "N " + latitudeString
        } else {
            return "S " + latitudeString
        }
    }
    
    func stringFromLongitude() -> String {
        var longitudeString = String(format: "%03d° ", abs(Int(self))) +
        String(format: "%05.2f'", abs(self.truncatingRemainder(dividingBy: 1)) * 60)
        
        // Generate correct cardinal suffix
        if self >= 0 {
            return "E " + longitudeString
        } else {
            return "W " + longitudeString
        }
    }
}
