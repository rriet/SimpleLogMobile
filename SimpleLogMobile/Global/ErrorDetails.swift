//
//  ErrorDetails.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/14/25.
//

import Foundation

struct ErrorDetails: LocalizedError {
    let title: String
    let message: String
    
    var errorDescription: String? {
        return "\(title): \(message)"
    }
    
    var recoverySuggestion: String? {
        return message
    }
}
