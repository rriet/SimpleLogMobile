//
//  NumericStepper.swift
//  SimpleLogMobile
//
//  Created by Ricardo Riet Correa on 25/02/2025.
//

import SwiftUI

struct NumericStepper: View {
    
    private let label: String
    @Binding private var value: Int
    private let minValue: Int?
    private let maxValue: Int?
    
    init(
        _ label: String,
        value: Binding<Int>,
        minValue: Int? = nil,
        maxValue: Int? = nil
    ) {
        self.label = label
        self._value = value
        self.minValue = minValue
        self.maxValue = maxValue
    }
    
    var body: some View {
        HStack {
            Text(label)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button {
                decrement()
            } label: {
                Image(systemName: "minus")
                    .frame(width: 38, height: 35)
            }
            .buttonStyle(.borderless)
            .foregroundColor(.green)
            Text("\(value)")
            Button {
                increment()
            } label: {
                Image(systemName: "plus")
                    .frame(width: 38, height: 35)
            }
            .buttonStyle(.borderless)
            .foregroundColor(.green)
        }
    }
    
    private func decrement() {
        if let minValue, value <= minValue {
            return
        }
        value -= 1
    }
    
    private func increment() {
        if let maxValue, value >= maxValue {
            return
        }
        value += 1
    }
}
