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
func isInteger(_ integerString: String, minValue: Double? = nil, maxValue: Double? = nil) throws {
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
func isDouble(_ doubleString: String, minValue: Double? = nil, maxValue: Double? = nil) throws {
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

func normalizePhoneNumber(_ phone: String) -> String? {
    let allowedCharacters = CharacterSet(charactersIn: "+0123456789")
    let normalizedPhone = phone.unicodeScalars
        .filter { allowedCharacters.contains($0) }
        .map { String($0) }
        .joined()
    
    return isValidPhoneNumber(normalizedPhone) ? normalizedPhone : nil
}

func isValidPhoneNumber(_ phone: String) -> Bool {
    // Regular expression for phone number validation
    // Allow international format and up to 15 digits (standard limit)
    let phoneRegex = "^[+]?[0-9]{1,15}$"
    return NSPredicate(format: "SELF MATCHES %@", phoneRegex).evaluate(with: phone)
}

func normalizeEmail(_ email: String) -> String? {
    let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    return isValidEmail(normalizedEmail) ? normalizedEmail : nil
}

func isValidEmail(_ email: String) -> Bool {
    // Simplified email regex (RFC 5322 compliant for most cases)
    let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
    return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
}
