//
//  ValidateInteger.swift
//  SimpleLog
//
//  Created by Ricardo Brito Riet Correa on 1/6/25.
//

import Foundation

/// Validates an integer string and checks against optional minimum and maximum values.
/// - Parameters:
///   - integerString: The string to validate as an integer.
///   - minValue: An optional minimum value.
///   - maxValue: An optional maximum value.
/// - Throws: A `ValidationError` if the input is invalid.
func validateInteger(_ integerString: String, minValue: Double? = nil, maxValue: Double? = nil) throws {
    // Attempt to parse the input string as an integer.
    guard let intValue = Int(integerString) else {
        throw ErrorDetails(
            title: "Error!",
            message: "Invalid number format.")
    }
    
    // Check if the integer is within the custom range (if provided).
    try numberRange(Double(intValue), minValue: minValue, maxValue: maxValue)
}

/// Validates a double string and checks against optional minimum and maximum values, and decimal place limits.
/// - Parameters:
///   - doubleString: The string to validate as a double.
///   - minValue: An optional minimum value.
///   - maxValue: An optional maximum value.
/// - Throws: A `ValidationError` if the input is invalid.
func validateDouble(_ doubleString: String, minValue: Double? = nil, maxValue: Double? = nil) throws {
    // Attempt to parse the input string as a double.
    guard let doubleValue = Double(doubleString) else {
        throw ErrorDetails(
            title: "Error!",
            message: "Invalid number format.")
    }
    
    // Check if the double is within the representable range of Double.
    // Use isInfinite for more accurate checking
    if doubleValue.isInfinite {
        throw ErrorDetails(
            title: "Error!",
            message: "Value is too large or too small.")
    }
    
    // Check the number of decimal places.
    // Limit to 6 decimal places, it's the limit for Double
    let components = doubleString.split(separator: ".")
    if components.count == 2 && components[1].count > 6 {
        throw ErrorDetails(
            title: "Error!",
            message: "Input exceeds the allowed number of decimals.")
    }
    
    // Check if the double is within the custom range (if provided).
    try numberRange(doubleValue, minValue: minValue, maxValue: maxValue)
}

/// Checks if a double value is within a specified range.
/// - Parameters:
///   - doubleValue: The value to check.
///   - minValue: An optional minimum value.
///   - maxValue: An optional maximum value.
/// - Throws: A `ValidationError` if the value is outside the range.
func numberRange(_ doubleValue: Double, minValue: Double? = nil, maxValue: Double? = nil) throws {
    if let min = minValue, doubleValue < min {
        throw ErrorDetails(
            title: "Error!",
            message: "Input value below min: \(min).")
    }
    
    if let max = maxValue, doubleValue > max {
        throw ErrorDetails(
            title: "Error!",
            message: "Input value above max: \(max)")
    }
}
