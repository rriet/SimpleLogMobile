//
//  SimpleLogMobileApp.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/11/25.
//

import SwiftUI

@main
struct SimpleLogMobileApp: App {
//    let viewContext = PersistenceController.shared.container.viewContext

    var body: some Scene {
        WindowGroup {
            MainView()
//                .environment(\.managedObjectContext, viewContext)
        }
    }
    
    init() {
//        print(URL.applicationSupportDirectory.path(percentEncoded: false))
    }
}
