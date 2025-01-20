//
//  Converters.swift
//  SimpleLog
//
//  Created by Ricardo Brito Riet Correa on 1/6/25.
//

import Foundation

/// Converts a string to an optional positive integer.
///
/// - Parameter stringValue: The string value to convert.
/// - Returns: An optional positive integer if the string is valid and greater than 0; otherwise, nil.
func stringToOptionalPositiveInt(_ stringValue: String) -> Int? {
    guard !stringValue.isEmpty, let value = Int(stringValue), value > 0 else {
        return nil
    }
    return value
}

func formatNumericValue<T: Numeric>(_ value: T) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.groupingSeparator = "," // Default separator based on locale
    formatter.maximumFractionDigits = value is Double ? 2 : 0 // Allow decimals only for Double
    return formatter.string(from: NSNumber(value: Double("\(value)") ?? 0)) ?? "\(value)"
}

