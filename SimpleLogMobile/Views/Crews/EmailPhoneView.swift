//
//  CallMessageEmail.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/19/25.
//

import SwiftUI

struct EmailPhoneView: View {
    
    var phone: String
    var email: String
    
    var body: some View {
        if let normPhone = normalizePhoneNumber(phone) {
            Button("Call") {
                guard let url = URL(string: "tel:\(normPhone)") else { return }
                UIApplication.shared.open(url)
            }
            Button("Message") {
                guard let url = URL(string: "sms:\(normPhone)") else { return }
                UIApplication.shared.open(url)
            }
            Button("Copy Phone") {
                UIPasteboard.general.string = normPhone
            }
        }
        
        if let normEmail = normalizeEmail(email) {
            Button("Email") {
                guard let url = URL(string: "mailto:\(normEmail)") else { return }
                UIApplication.shared.open(url)
            }
            Button("Copy email") {
                UIPasteboard.general.string = normEmail
            }
        }
        
        
        Button("Cancel", role: .cancel) { }
    }
}
