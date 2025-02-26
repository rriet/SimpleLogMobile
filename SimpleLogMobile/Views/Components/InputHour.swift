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
    @State private var isUpdating: Bool = false
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
                    HStack {
                        Text("\(title)")
                            .lineLimit(1)
                            .frame(minWidth: 80, alignment: .leading)
                        DatePicker(
                            "",
                            selection: $date,
                            displayedComponents: .hourAndMinute
                        )
                        .labelsHidden()
                    }
                case .text:
                HStack(alignment: .center) {
                    Text("\(title)")
                        .frame(minWidth: 70, alignment: .leading)
                    VStack{
                        TextField("", text: $timeText)
                            .keyboardType(.numberPad)
                            .frame(width: 70, height: 35)
                            .background(backgroundColor)
                            .multilineTextAlignment(.center)
                            .cornerRadius(7)
                            .toolbar { keyboardToolbar }
                            .focused($isFocused)
                            .onChange(of: isFocused, handleFocusChange)
                            .onChange(of: timeText, timeTextChanged)
                            .onAppear {
                                // Initialize the text field with the current time
                                setTextFromDate(date)
                            }
                            .onChange(of: date) { oldDate, newDate in
                                // Update the text field when the date changes externaly
                                setTextFromDate(newDate)
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
    }
    
    // MARK: - Keyboard Toolbar
        private var keyboardToolbar: some ToolbarContent {
            ToolbarItemGroup(placement: .keyboard) {
                if isFocused {
                    Spacer()
                    Button("Done") { isFocused = false }
                }
            }
        }
    
    // MARK: - UI functions
    
    private func handleFocusChange(){
        
        // lost focus
        if !isFocused {
            var cleanInput = timeText.filter { $0.isNumber }
            cleanInput = String(repeating: "0", count: max(0, 4 - cleanInput.count)) + cleanInput
            
            let hours = String(cleanInput.prefix(2))
            let minutes = String(cleanInput.suffix(cleanInput.count - 2))
            updateTimeText("\(hours):\(minutes)")
            
            validateTime()
        }
        
        // Reset isEditing when focus gain or loss
        isEditing = false
    }
    
    private func timeTextChanged(_ oldValue: String, _ newValue: String) {
        // only do something if the TextField has focus and the change was done by the user
        if isUpdating {
            return
        }
        
        if !isEditing {
            firstUserInput(oldValue, newValue)
            return
        }
        
        var cleanInput = newValue.filter { $0.isNumber }
        
        // Automatically insert ":" after the first one or two digits
        // 100 becomes 1:00 and 1000 becomes 10:00
        if cleanInput.count < 3 {
            updateTimeText(cleanInput)
        }else if cleanInput.count == 3 {
            let hours = String(cleanInput.prefix(1))
            let minutes = String(cleanInput.suffix(cleanInput.count - 1))
            updateTimeText("\(hours):\(minutes)")
        } else {
            // Limit to 4 digits
            if cleanInput.count > 4 {
                cleanInput = String(cleanInput.suffix(4))
            }
            let hours = String(cleanInput.prefix(2))
            let minutes = String(cleanInput.suffix(cleanInput.count - 2))
            updateTimeText("\(hours):\(minutes)")
        }
        
        if timeText.count == 5 {
            validateTime()
        }
        
    }
    
    private func firstUserInput(_ oldValue: String, _ newValue: String) {
        isEditing = true
        backgroundColor = Color.yellow
        
        for digit in "0123456789" {
            let countInOriginal = oldValue.filter { $0 == digit }.count
            let countInModified = newValue.filter { $0 == digit }.count
            
            if countInModified > countInOriginal {
                updateTimeText(String(digit))
                return
            }
        }
        updateTimeText("")
    }
    
    private func setTextFromDate(_ newDate: Date) {
        isEditing = false
        isInvalid = false
        backgroundColor = Color.theme.secondaryBackground
        
        // Set time to received Date
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        updateTimeText(formatter.string(from: newDate))
    }
    
    // MARK: - Auxiliary functions
    
    // function prevents the change in timeText to trigger the onChange function
    private func updateTimeText(_ newText: String) {
        isUpdating = true
        timeText = newText
        DispatchQueue.main.async {
            self.isUpdating = false
        }
    }
    
    private func isValidTime(_ time: String) -> Bool {
        return time.range(of: #"^([01]\d|2[0-3]):([0-5]\d)$"#, options: .regularExpression) != nil
    }
    
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
    
    private func setDate(_ input: String) {
        if isValidTime(input) {
            isInvalid = false
            backgroundColor = Color.theme.secondaryBackground
            
            let hour = Int(input.prefix(2)) ?? 0
            let minute = Int(input.suffix(2)) ?? 0
            
            // Update the date with the validated time
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day], from: date)
            components.hour = hour
            components.minute = minute
            if let newDate = calendar.date(from: components) {
                date = newDate
            }
        } else {
            isEditing = true
            isInvalid = true
            backgroundColor = Color.red
        }
    }
}
