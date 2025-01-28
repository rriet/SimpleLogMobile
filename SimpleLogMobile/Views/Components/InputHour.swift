//
//  HourField.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/28/25.
//

import SwiftUI

struct InputHour: View {
    @Binding var date: Date
    var mode: Mode
    var title: String
    
    @State private var timeText: String = ""
    @State private var isInvalidTime: Bool = false
    @State private var originalTimeText: String = ""
    
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
                    VStack{
                        TextField("", text: $timeText, onEditingChanged: onEditingChanged)
                            .keyboardType(.numberPad)
                            .onChange(of: timeText) { oldValue, newValue in
                                // Ensure only numbers are entered
                                timeText = newValue.filter { $0.isNumber }
                                
                                // Limit to 4 digits
                                if timeText.count > 4 {
                                    timeText = String(timeText.suffix(4))
                                }
                                
                                // Automatically insert ":" after the first one or two digits
                                // 100 becomes 1:00 and 1000 becomes 10:00
                                if timeText.count == 3 {
                                    let hour = String(timeText.prefix(1))
                                    let minute = String(timeText.suffix(timeText.count - 1))
                                    timeText = "\(hour):\(minute)"
                                } else if timeText.count == 4 {
                                    let hour = String(timeText.prefix(2))
                                    let minute = String(timeText.suffix(timeText.count - 2))
                                    timeText = "\(hour):\(minute)"
                                }
                            }
                            .onSubmit(validateTime)
                            .onChange(of: timeText) { oldValue, newValue  in
                                // only validate if 5 digits are entered
                                if newValue.count == 5 {
                                    // Validate on loss of focus
                                    validateTime()
                                }
                            }
                        if isInvalidTime {
                            Text("Invalid time")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
            }
        }
        .onAppear {
            // Initialize the text field with the current time
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            timeText = formatter.string(from: date)
        }
        .onChange(of: date) { oldDate, newDate in
            // Update the text field when the date changes
            if mode == .text {
                updateTimeText(from: newDate)
            }
        }

    }
    
    private func onEditingChanged(editingChanged: Bool){
        if editingChanged {
            // gain foccus
            originalTimeText = timeText
            // async change because of view update not working when editing
            DispatchQueue.main.async {
                timeText = ""
            }
        } else {
            // lost foccus
            if timeText.isEmpty {
                DispatchQueue.main.async {
                    timeText = originalTimeText
                }
            } else {
                // Pad with leading zeros if the length is less than 4
                DispatchQueue.main.async {
                    while timeText.count < 5 {
                        timeText = "0" + timeText
                    }
                }
                validateTime()
            }
        }
    }
    
    private func updateTimeText(from date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        timeText = formatter.string(from: date)
    }
    
    private func validateTime() {
        // Remove the ":" for validation
        let rawTime = timeText.replacingOccurrences(of: ":", with: "")
        
        guard rawTime.count == 4 else {
            isInvalidTime = true
            return
        }
        
        let hour = Int(rawTime.prefix(2)) ?? 0
        let minute = Int(rawTime.suffix(2)) ?? 0
        
        if hour >= 0 && hour < 24 && minute >= 0 && minute < 60 {
            isInvalidTime = false
            
            // Update the date with the validated time
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day], from: date)
            components.hour = hour
            components.minute = minute
            if let newDate = calendar.date(from: components) {
                date = newDate
            }
        } else {
            isInvalidTime = true
        }
    }
}
