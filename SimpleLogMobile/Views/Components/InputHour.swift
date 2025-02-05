//
//  HourField.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/28/25.
//

import SwiftUI

struct InputHour: View {
    
    // MARK: - Input Variables
    @Binding var date: Date
    var mode: Mode
    var title: String
    @State var isEditing: Bool = false
    
    // MARK: - Control Variables
    @State private var timeText: String = ""
    @State private var isInvalid: Bool = false
    @State private var isUpdating: Bool = true
    @State private var backgroundColor: Color = Color.theme.secondaryBackground
    @FocusState private var isFocused: Bool

    
    enum Mode: String, Codable, CaseIterable {
        case picker
        case text
        
        var description: String {
            switch self {
                case .picker:
                    return "Time Picker"
                case .text:
                    return "Text Field"
            }
        }
    }
    
    // MARK: - View
    var body: some View {
        HStack(alignment: .top) {
            switch mode {
                case .picker:
                    DatePicker(
                        title,
                        selection: $date,
                        displayedComponents: .hourAndMinute
                    )
                case .text:
                    Text("\(title):")
                    Spacer()
                    VStack{
                        TextField("", text: $timeText)
                            .keyboardType(.numberPad)
                            .frame(width: 60, height: 30)
                            .background(backgroundColor)
                            .multilineTextAlignment(.center)
                            .cornerRadius(5)
                            .toolbar {
                                if isFocused {
                                    ToolbarItemGroup(placement: .keyboard) {
                                        Spacer()
                                        Button("Done") {
                                            isFocused = false
                                        }
                                    }
                                }
                            }
                            .focused($isFocused)
                            .onChange(of: isFocused, focusedChanged)
                            .onChange(of: timeText, timeTextChanged)
                            .onAppear {
                                // Initialize the text field with the current time
                                updateTimeText(from: date)
                            }
                            .onChange(of: date) { oldDate, newDate in
                                // Update the text field when the date changes externaly
                                updateTimeText(from: newDate)
                            }
                    if isInvalid {
                        Text("Invalid time")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
        }
    }
    
    // MARK: - UI functions
    
    private func focusedChanged(){
        if !isFocused {
            // lost focus
            doneEditing()
        }
        
        // Reset isEditing when focus gain or loss
        isEditing = false
    }
    
    private func timeTextChanged(_ oldValue: String, _ newValue: String) {
        
        // only do something if the TextField has focus
        if !isUpdating && isFocused {
            backgroundColor = Color.yellow
            
            // First time the user types something
            if !isEditing {
                // Clean the text field and leave only the new number
                firstInput(oldValue, newValue)
                return
            }
            
            // if not the first character, format string
            timeText = formatTimeString(newValue)
            
            if timeText.count == 5 {
                validateTime()
            }
        }
        isUpdating = false
    }
    
    private func updateTimeText(from date: Date) {
        isUpdating = true
        // if time was modified, reset time display
        isEditing = false
        isInvalid = false
        backgroundColor = Color.theme.secondaryBackground
        
        // Set time to received Date
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        timeText = formatter.string(from: date)
    }
    
    // MARK: - Auxiliary functions
    
    private func firstInput(_ oldValue: String, _ newValue: String) {
        isEditing = true
        
        // if user added a new char, get the char
        if newValue.count > oldValue.count {
            for digit in "0123456789" {
                let countInOriginal = oldValue.filter { $0 == digit }.count
                let countInModified = newValue.filter { $0 == digit }.count
                
                if countInModified > countInOriginal {
                    timeText = String(digit)
                    return
                }
            }
        }
        // if the user removed a char or no new number was found
        timeText = ""
    }
    
    private func formatTimeString(_ input: String) -> String {
        // Remove any non numeric characters (including colons ":")
        var cleanInput = input.filter { $0.isNumber }
        
        // Automatically insert ":" after the first one or two digits
        // 100 becomes 1:00 and 1000 becomes 10:00
        if cleanInput.count < 3 {
            return cleanInput
        }else if cleanInput.count == 3 {
            let hours = String(cleanInput.prefix(1))
            let minutes = String(cleanInput.suffix(cleanInput.count - 1))
            return "\(hours):\(minutes)"
        } else {
            // Limit to 4 digits
            if cleanInput.count > 4 {
                cleanInput = String(cleanInput.suffix(4))
            }
            let hours = String(cleanInput.prefix(2))
            let minutes = String(cleanInput.suffix(cleanInput.count - 2))
            return "\(hours):\(minutes)"
        }
    }
    
    
    // when user finished editing, add leading zeroes and check value
    private func doneEditing() {
        // Remove any non numeric characters (including colons ":")
        timeText = timeText.filter { $0.isNumber }
        
        // Pad with leading zeros to ensure at least 4 characters
        timeText = String(repeating: "0", count: max(0, 4 - timeText.count)) + timeText
        
        timeText = formatTimeString(timeText)

        validateTime()
    }
    
    // check if the time is valid and in the format "HH:MM"
    private func validateTime() {
        if isValidTime(timeText) {
            // Valid
            isInvalid = false
            backgroundColor = Color.theme.secondaryBackground
            setDate(timeText)
        } else {
            // Invalid
            isInvalid = true
            backgroundColor = Color.red
        }
    }
    
    private func isValidTime(_ time: String) -> Bool {
        return time.range(of: #"^([01]\d|2[0-3]):([0-5]\d)$"#, options: .regularExpression) != nil
    }
    
    private func setDate(_ input: String) {
        if isValidTime(input) {
            isInvalid = false
            
            let hour = Int(input.prefix(2)) ?? 0
            let minute = Int(input.suffix(2)) ?? 0
            
            backgroundColor = Color.theme.secondaryBackground
            
            // Update the date with the validated time
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day], from: date)
            components.hour = hour
            components.minute = minute
            if let newDate = calendar.date(from: components) {
                date = newDate
                isUpdating = false
            }
        } else {
            isEditing = true
            isInvalid = true
            backgroundColor = Color.red
        }
    }
}
