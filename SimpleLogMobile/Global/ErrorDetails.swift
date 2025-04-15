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
    let severity: Severity
    
    enum Severity {
        case error
        case warning
        case info
    }
}
