//
//  Unwrappers.swift
//  SimpleLog
//
//  Created by Ricardo Brito Riet Correa on 12/23/24.
//

import Foundation

extension Optional where Wrapped == String {
    var strUnwrap: String {
        return self ?? ""
    }
}

extension Optional where Wrapped == Int {
    var intUnwrap: Int {
        return self ?? 0
    }
}

extension Optional where Wrapped == Double {
    var doubleUnwrap: Double {
        return self ?? 0
    }
}
