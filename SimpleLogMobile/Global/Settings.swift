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
        static let hourInputMode = "hourInputMode"
    }
    
    static var autoLockNewEntries: Bool {
        get {
            defaults.bool(forKey: Keys.autoLockNewEntries)
        }
        set {
            defaults.set(newValue, forKey: Keys.autoLockNewEntries)
        }
    }
    
    static var hourInputMode: InputHour.Mode {
        get {
            guard let data = defaults.data(forKey: Keys.hourInputMode) else {
                return InputHour.Mode.text
            }
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode(InputHour.Mode.self, from: data) {
                return decoded
            }
            return InputHour.Mode.text
        }
        set {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(newValue) {
                defaults.set(encoded, forKey: Keys.hourInputMode)
            }
        }
    }
    
    
}
