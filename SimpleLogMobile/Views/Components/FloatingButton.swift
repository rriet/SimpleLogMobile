//
//  FloatingButton.swift
//  SimpleLog
//
//  Created by Ricardo Brito Riet Correa on 1/10/25.
//

import SwiftUI

extension View {
    func floatingButton(
        buttonContent: AnyView,
        action: @escaping () -> Void
    ) -> some View {
        self.modifier(FloatingButtonModifier(buttonContent: buttonContent, action: action))
    }
}

struct FloatingButtonModifier: ViewModifier {
    var buttonContent: AnyView
    var action: () -> Void
    
    func body(content: Content) -> some View {
        ZStack {
            content // The original view being modified
            
            VStack {
                Spacer() // Push to the bottom
                HStack {
                    Spacer() // Push to the right
                    Button(action: {
                        action()
                    }) {
                        buttonContent
                    }
                    .padding()
                    .background(Circle().fill(Color.blue))
                    .foregroundColor(.white)
                    .shadow(radius: 4)
                }
            }
            .padding([.bottom], 15)
            .padding([.trailing], 30)
        }
    }
}
