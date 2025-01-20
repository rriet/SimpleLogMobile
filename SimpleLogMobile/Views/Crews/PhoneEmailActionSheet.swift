//
//  CallMessageEmail.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/19/25.
//



import SwiftUI

struct EmailPhoneActionSheet {
    
    static func getActionSheet(email: String, phone: String) -> ActionSheet {
        var buttonsArray: [ActionSheet.Button] = []
        
        // Helper function to create URLs safely
        func createURL(for scheme: String, value: String) -> URL? {
            return URL(string: "\(scheme):\(value)")
        }
        
        // Normalize and add buttons for phone if valid
        if let normPhone = normalizePhoneNumber(phone) {
            let buttonPhone: ActionSheet.Button = .default(
                Text("Call"),
                action: {
                    guard let url = createURL(for: "tel", value: normPhone) else { return }
                    UIApplication.shared.open(url)
                }
            )
            let buttonMessage: ActionSheet.Button = .default(
                Text("Message"),
                action: {
                    guard let url = createURL(for: "sms", value: normPhone) else { return }
                    UIApplication.shared.open(url)
                }
            )
            
            // Button for copying email to clipboard
            let buttonCopyPhone: ActionSheet.Button = .default(
                Text("Copy Phone"),
                action: {
                    UIPasteboard.general.string = normPhone
                }
            )
            
            buttonsArray.append(buttonPhone)
            buttonsArray.append(buttonMessage)
            buttonsArray.append(buttonCopyPhone)
        }
        
        // Normalize and add buttons for email if valid
        if let normEmail = normalizeEmail(email) {
            let buttonEmail: ActionSheet.Button = .default(
                Text("Email"),
                action: {
                    guard let url = createURL(for: "mailto", value: normEmail) else { return }
                    UIApplication.shared.open(url)
                }
            )
            buttonsArray.append(buttonEmail)
            
            // Button for copying email to clipboard
            let buttonCopyEmail: ActionSheet.Button = .default(
                Text("Copy Email"),
                action: {
                    UIPasteboard.general.string = normEmail
                }
            )
            buttonsArray.append(buttonCopyEmail)
        }
        
        // Cancel button
        buttonsArray.append(.cancel())
        
        return ActionSheet(
            title: Text("Select Action:"),
            buttons: buttonsArray
        )
    }
}
