//
//  AlertHelper.swift
//  SimpleLog
//
//  Created by Ricardo Brito Riet Correa on 1/1/25.
//

import SwiftUI

enum AlertConfiguration {
    case simple(title: String, message: String)
    case confirmation(title: String, message: String, confirmAction: () -> Void)
}

struct AlertInfo: Identifiable {
    let id = UUID()
    let configuration: AlertConfiguration
}

class AlertManager: ObservableObject {
    @Published var currentAlert: AlertInfo?
    
    func showAlert(_ configuration: AlertConfiguration) {
        currentAlert = AlertInfo(configuration: configuration)
    }
    
    func getAlert(_ alertInfo: AlertInfo) -> Alert {
        switch alertInfo.configuration {
            case .simple(let title, let message):
                return Alert(title: Text(title), message: Text(message), dismissButton: .default(Text("OK")))
            case .confirmation(let title, let message, let confirmAction):
                return Alert(
                    title: Text(title),
                    message: Text(message),
                    primaryButton: .destructive(Text("Confirm"), action: confirmAction),
                    secondaryButton: .cancel()
                )
        }
    }
}
