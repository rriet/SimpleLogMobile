//
//  SimpleLogMobileApp.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/11/25.
//

import SwiftUI

@main
struct SimpleLogMobileApp: App {
    
    // Create AlertManager instance
    @StateObject private var alertManager = AlertManager.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .alert(
                    alertManager.title,
                    isPresented: $alertManager.isPresentingAlert
                ) {
                    if let confirmAction = alertManager.confirmAction {
                        Button("Cancel", role: .cancel) { alertManager.dismissAlert() }
                        Button("Confirm", role: .destructive) {
                            confirmAction()
                            alertManager.dismissAlert()
                        }
                    } else {
                        Button("OK") { alertManager.dismissAlert() }
                    }
                } message: {
                    Text(alertManager.message)
                }
        }
    }
    
    init() {
//        print(URL.applicationSupportDirectory.path(percentEncoded: false))
    }
}
