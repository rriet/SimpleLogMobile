//
//  NumericTextField.swift
//  SimpleLog
//
//  Created by Ricardo Brito Riet Correa on 1/3/25.
//

import SwiftUI

/// A custom `TextField` that only accepts numeric input with optional decimal and negative values.
struct NumericField: View {
    // Placeholder text for the TextField
    private let placeholder: String
    // Bound value for the TextField's text
    @Binding private var textValue: String
    // Flag to indicate if the input is invalid
    @Binding private var isInvalid: Bool
    // Indicates if the field is required
    private let isRequired: Bool
    // Optional minimum value for validation
    private let minValue: Double?
    // Optional maximum value for validation
    private let maxValue: Double?
    // Defines the type of input allowed
    private let inputType: InputType
    
    @State private var errorMessage: String = "" // Error message displayed for invalid input
    
    /// Enumeration of possible input types for validation.
    enum InputType {
        case integer
        case positiveInteger
        case double
        case positiveDouble
    }
    
    /// Initializes a new `NumericField`.
    ///
    /// - Parameters:
    ///   - placeholder: The placeholder text to display in the text field.
    ///   - textValue: Bound value representing the field's text.
    ///   - isInvalid: Bound boolean indicating if the input is invalid.
    ///   - isRequired: Boolean indicating whether the field is required.
    ///   - minValue: Minimum acceptable value for validation.
    ///   - maxValue: Maximum acceptable value for validation.
    ///   - inputType: The type of numeric input allowed.
    init(
        _ placeholder: String,
        textValue: Binding<String>,
        isInvalid: Binding<Bool>? = nil,
        isRequired: Bool = false,
        minValue: Double? = nil,
        maxValue: Double? = nil,
        inputType: InputType
    ) {
        self.placeholder = placeholder
        self._textValue = textValue
        self._isInvalid = isInvalid ?? .constant(false)
        self.isRequired = isRequired
        self.minValue = minValue
        self.maxValue = maxValue
        self.inputType = inputType
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Text("\(placeholder):")
                    .foregroundColor(.secondary) // Label for the text field
                
                VStack(alignment: .leading) {
                    TextField(isRequired ? "Required" : "", text: $textValue)
                    // Sets the keyboard type based on inputType
#if os(iOS)
                        .keyboardType(keyboardType)
#endif
                    // Disables autocorrection
                        .autocorrectionDisabled()
                    // Workaround for an Apple bug
                        .onLongPressGesture(minimumDuration: 0.0) { }
                    // Validates input when the text changes
                        .onChange(of: textValue, validateInput)
                    // Validates input on initial appearance
                        .onAppear {
                            validateInput(oldValue: textValue, newValue: textValue)
                        }
                    
                    // Displays the error message if the input is invalid
                    if isInvalid {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
#if os(iOS)
    /// Determines the appropriate keyboard type based on the input type.
    private var keyboardType: UIKeyboardType {
        switch inputType {
            case .double, .integer:
                return .numbersAndPunctuation // Allows numbers and punctuation (e.g., "-")
            case .positiveDouble:
                return .decimalPad // Decimal pad without negative sign
            case .positiveInteger:
                return .numberPad // Number pad without decimal or negative sign
        }
    }
#endif
    
    /// Validates the input string and updates the `textValue` binding and `isInvalid` state.
    ///
    /// - Parameters:
    ///   - oldValue: The previous value of the text field.
    ///   - newValue: The current value of the text field.
    private func validateInput(oldValue: String, newValue: String) {
        // Trim whitespace from the beginning and end of the input
        let trimmedInput = newValue.trimmingCharacters(in: .whitespaces)
        
        // Update the textValue with the trimmed input
        textValue = trimmedInput
        
        // If the field is required but empty, mark as invalid
        if trimmedInput.isEmpty {
            if isRequired {
                isInvalid = true
                errorMessage = "Required!"
            } else {
                isInvalid = false
            }
            return
        }
        
        // Handle intermediate cases while the user is typing
        if trimmedInput == "-" && (inputType == .integer || inputType == .double) {
            errorMessage = ""
            isInvalid = true
            return
        } else if trimmedInput == "." && (inputType == .double || inputType == .positiveDouble) {
            errorMessage = ""
            isInvalid = true
            textValue = "0."
            return
        } else if trimmedInput == "-." && inputType == .double {
            errorMessage = ""
            isInvalid = true
            textValue = "-0."
            return
        }
        
        // Define the regular expression for valid input
        let regex: String
        switch inputType {
            case .double:
                regex = "^-?\\d*(\\.\\d*)?$" // Allows numbers with optional "-" and "."
            case .integer:
                regex = "^-?\\d+$" // Allows numbers with optional "-"
            case .positiveDouble:
                regex = "^\\d*(\\.\\d*)?$" // Only positive numbers with optional "."
            case .positiveInteger:
                regex = "^\\d+$" // Only positive integers
        }
        
        // Ensure the input matches the regex
        guard trimmedInput.range(of: regex, options: .regularExpression) != nil else {
            // Revert to the previous valid value
            textValue = oldValue.trimmingCharacters(in: .whitespaces)
            return
        }
        
        // Perform numeric validation based on the input type
        do {
            if inputType == .integer || inputType == .positiveInteger {
                try validateInteger(trimmedInput, minValue: minValue, maxValue: maxValue)
            } else {
                try validateDouble(trimmedInput, minValue: minValue, maxValue: maxValue)
            }
        } catch {
            isInvalid = true
            errorMessage = "\(error.localizedDescription)" // Display the error message
            return
        }
        
        isInvalid = false // Mark as valid if no errors are encountered
    }
}
