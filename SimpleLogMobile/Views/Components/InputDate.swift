//
//  InputDate.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/28/25.
//

import SwiftUI

struct InputDate: View {
    
    var title: String
    @Binding var dateStart: Date
    
    var body: some View {
        HStack {
            Text("\(title):")
                .foregroundColor(.secondary)
            
            Spacer()
            
            // Decrease date button
            Button(action: {
                dateStart = Calendar.current.date(byAdding: .day, value: -1, to: dateStart) ?? dateStart
            }) {
                Image(systemName: "chevron.left")
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.borderless) // Add styling as needed
            
            // DatePicker in the center
            DatePicker(
                "",
                selection: $dateStart,
                displayedComponents: .date
            )
            .labelsHidden() // Hides the label to keep it compact
            .background(Color.clear) // Remove the default background
            .border(Color.clear) // Remove the default border
            
            // Increase date button
            Button(action: {
                dateStart = Calendar.current.date(byAdding: .day, value: 1, to: dateStart) ?? dateStart
            }) {
                Image(systemName: "chevron.right")
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.borderless) // Add styling as needed
        }
    }
}
