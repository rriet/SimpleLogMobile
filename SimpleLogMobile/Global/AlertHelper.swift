//
//  AlertHelper.swift
//  SimpleLog
//
//  Created by Ricardo Brito Riet Correa on 1/1/25.
//

import SwiftUI

class AlertManager: ObservableObject {
    static let shared = AlertManager()
    
    @Published var isPresentingAlert: Bool = false
    @Published var title: String = ""
    @Published var message: String = ""
    @Published var confirmAction: (() -> Void)?
    
    func showAlert(title: String, message:String, confirmAction:(() -> Void)? = nil) {
        // delay 0.01 seconds to allow a alert to trigger another alert.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.title = title
            self.message = message
            self.confirmAction = confirmAction
            self.isPresentingAlert = true
        }
    }
    
    func dismissAlert() {
        DispatchQueue.main.async {
            self.isPresentingAlert = false
        }
    }
}

func handleError(_ error: Error) {
    if let details = error as? ErrorDetails {
        AlertManager.shared.showAlert(
            title: details.title,
            message: details.message
        )
    } else {
        AlertManager.shared.showAlert(
            title: "Unexpected Error",
            message: error.localizedDescription
        )
    }
}
