//
//  CustomTextField.swift
//  SimpleLog
//
//  Created by Ricardo Brito Riet Correa on 1/4/25.
//

import SwiftUI

/// A custom `TextField` with validation for different formats.
struct InputField: View {
    private let placeholder: String
    @Binding private var text: String
    @Binding private var isInvalid: Bool
    private let isRequired: Bool
    private let minLength: Int?
    private let maxLength: Int?
    private let lines: Int
    private let inputType: InputType
    private let capitalization: TextInputAutocapitalization
    
    // Custom validation closure
    private let validation: ((String) -> ErrorType?)?
    
    @State private var errorCode: ErrorType?
    
    /// Enumeration of possible input types for validation.
    enum InputType {
        case letters
        case lettersAndNumbers
        case email
        case any
    }
    
    /// Enumeration of possible validation error types.
    enum ErrorType: Hashable {
        case required
        case minLength(Int)
        case maxLength(Int)
        case invalidFormat(String)
    }
    
    /// Initializes a new `InputField`.
    /// - Parameters:
    ///   - placeholder: The placeholder text to display in the text field.
    ///   - textValue: A binding to the text value.
    ///   - isInvalid: A binding to the validation state (true if invalid).
    ///   - isRequired: A boolean indicating if the field is required.
    ///   - minLength: The minimum allowed length of the input.
    ///   - maxLength: The maximum allowed length of the input.
    ///   - lines: The number of lines of the input.
    ///   - inputType: The type of input to validate.
    ///   - capitalization: The capitalization style for the text input.
    ///   - customValidation: Optional custom validation function (returns InputField.ErrorType? )
    init(
        _ placeholder: String,
        textValue: Binding<String>,
        isInvalid: Binding<Bool>? = nil,
        isRequired: Bool = false,
        minLength: Int? = nil,
        maxLength: Int? = nil,
        lines: Int = 1,
        inputType: InputType = .any,
        capitalization: TextInputAutocapitalization = .never,
        customValidation: ((String) -> ErrorType?)? = nil
    ) {
        self.placeholder = placeholder
        self._text = textValue
        self._isInvalid = isInvalid ?? .constant(false)
        self.isRequired = isRequired
        self.minLength = minLength
        self.maxLength = maxLength
        self.lines = lines
        self.inputType = inputType
        self.capitalization = capitalization
        self.validation = customValidation
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Text("\(placeholder):")
                    .foregroundColor(.secondary)
                
                VStack (alignment: .leading){
                    TextField(
                        isRequired ? "Required" : "",
                        text: $text,
                        axis: lines > 1 ? .vertical : .horizontal)
#if os(iOS)
                        .keyboardType(keyboardType)
#endif
                        .autocorrectionDisabled()
                    /// Avoid Apple BUG https://forums.developer.apple.com/forums/thread/738726
                        .onLongPressGesture(minimumDuration: 0.0) { }
                        .textInputAutocapitalization(capitalization)
                        .onChange(of: text, validateInput)
                        .onAppear(perform: validateInput)
                        .lineLimit(lines...lines)
                    if let errorCode = errorCode {
                        Text(errorDescription(for: errorCode))
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
            }
        }
    }
    
    /// Validates the input string and updates the `isInvalid` state and `errorCode`.
    private func validateInput() {
        let trimmedInput = text.trimmingCharacters(in: .whitespaces)
        errorCode = nil // Reset error code at the beginning of validation
        isInvalid = false // Reset isInvalid state
        
        if trimmedInput.isEmpty && isRequired {
            errorCode = .required
            isInvalid = true
            return
        }
        
        if let min = minLength, trimmedInput.count < min {
            errorCode = .minLength(min)
            isInvalid = true
            return
        }
        
        if let max = maxLength, trimmedInput.count > max {
            errorCode = .maxLength(max)
            isInvalid = true
            return
        }
        
        var regex: String
        var regexError: String = ""
        
        switch inputType {
            case .letters:
                regex = "^[a-zA-Z]+$"
                regexError = "Only letters are allowed."
            case .lettersAndNumbers:
                regex = "^[a-zA-Z0-9]+$"
                regexError = "Only letters and numbers are allowed."
            case .email:
                regex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,}$"
                regexError = "Invalid email format."
            case .any:
                // No validation needed for "any" input type
                regex = ""
        }
        
        if !regex.isEmpty && !trimmedInput.isEmpty {
            guard trimmedInput.range(of: regex, options: .regularExpression) != nil else {
                errorCode = .invalidFormat(regexError)
                isInvalid = true
                return
            }
        }
        
        // Custom validation check only runs if the text value was modified
        if let customError = validation?(trimmedInput) {
            errorCode = customError
            isInvalid = true
            return
        }
    }
    
    /// Returns the error description for a given `ErrorType`.
    /// - Parameter code: The `ErrorType` to get the description for.
    /// - Returns: The error description string.
    private func errorDescription(for code: ErrorType) -> String {
        switch code {
            case .required:
                return "Required!"
            case .minLength(let length):
                return "Minimum length is \(length)."
            case .maxLength(let length):
                return "Maximum length is \(length)."
            case .invalidFormat(let message):
                return message
        }
    }
#if os(iOS)
    /// Returns the appropriate keyboard type for the input type.
    private var keyboardType: UIKeyboardType {
        switch inputType {
            case .letters, .lettersAndNumbers:
                return .asciiCapable
            case .email:
                return .emailAddress
            case .any:
                return .default
        }
    }
#endif
}
