//
//  CrewModel.swift
//  SimpleLogMobile
//
//  Created by Ricardo Riet Correa on 15/02/2025.
//

import Foundation

struct CrewModel {
    var name: String = ""
    var email: String = ""
    var phone: String = ""
    var notes: String = ""
    var picture: Data? = nil
    var isLocked: Bool = AppSettings.autoLockNewEntries
    var isFavorite: Bool = false
    
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    init(
        name: String = "",
        email: String = "",
        phone: String = "",
        notes: String = "",
        picture: Data? = nil,
        isLocked: Bool = AppSettings.autoLockNewEntries,
        isFavorite: Bool = false) {
        
        self.name = name.trimmingCharacters(in: .whitespaces)
        self.email = email.trimmingCharacters(in: .whitespaces)
        self.phone = phone.trimmingCharacters(in: .whitespaces)
        self.notes = notes
        self.picture = picture
        self.isLocked = isLocked
        self.isFavorite = isFavorite
    }
    
    init(crew: Crew) {
        self.name = crew.name?.trimmingCharacters(in: .whitespaces) ?? ""
        self.email = crew.email?.trimmingCharacters(in: .whitespaces) ?? ""
        self.phone = crew.phone?.trimmingCharacters(in: .whitespaces) ?? ""
        self.notes = crew.notes ?? ""
        self.picture = crew.picture
        self.isLocked = crew.isLocked
        self.isFavorite = crew.isFavorite
    }
    
    mutating func update(from coreDataCrew: Crew) {
        self.name = coreDataCrew.name ?? ""
        self.email = coreDataCrew.email ?? ""
        self.phone = coreDataCrew.phone ?? ""
        self.notes = coreDataCrew.notes ?? ""
        self.picture = coreDataCrew.picture
        self.isLocked = coreDataCrew.isLocked
        self.isFavorite = coreDataCrew.isFavorite
    }
}
