//
//  Settings.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/28/25.
//

import Foundation

struct AppSettings {
    private static let defaults = UserDefaults.standard
    
    // Keys for UserDefaults
    enum Keys {
        static let autoLockNewEntries = "autoLockNewEntries"
        static let logTakeOffAndLanding = "logTakeOffAndLanding"
        static let hourInputMode = "hourInputMode"
        static let autoSelectAirport = "autoSelectAirport"
        static let autoSelectAircraft = "autoSelectAircraft"
    }
    
    static var autoLockNewEntries: Bool {
        get {
            defaults.bool(forKey: Keys.autoLockNewEntries)
        }
        set {
            defaults.set(newValue, forKey: Keys.autoLockNewEntries)
        }
    }
    
    static var logTakeOffAndLanding: Bool {
        get {
            defaults.bool(forKey: Keys.logTakeOffAndLanding)
        }
        set {
            defaults.set(newValue, forKey: Keys.logTakeOffAndLanding)
        }
    }
    
    static var hourInputMode: InputHour.Mode {
        get {
            // Default to .text if no value is stored
            guard let rawValue = defaults.string(forKey: Keys.hourInputMode) else {
                return .text
            }
            
            // Try to create an enum value from the rawValue string
            return InputHour.Mode(rawValue: rawValue) ?? .text
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.hourInputMode)
        }
    }
    
    static var autoSelectAirport: Bool {
        get {
            defaults.bool(forKey: Keys.autoSelectAirport)
        }
        set {
            defaults.set(newValue, forKey: Keys.autoSelectAirport)
        }
    }
    
    static var autoSelectAircraft: Bool {
        get {
            defaults.bool(forKey: Keys.autoSelectAircraft)
        }
        set {
            defaults.set(newValue, forKey: Keys.autoSelectAircraft)
        }
    }
}
