//
//  SelectedMenuView.swift
//  SimpleLog
//
//  Created by Ricardo Brito Riet Correa on 12/22/24.
//

import SwiftUI

struct SelectedMenuView: View {
    
    @Binding var selectedView: MenuLink
    
    var body: some View {
        switch selectedView {
            case .LogbookView:
                Text("Logbook")
//                ContentView()
//                LogbookView()
            case .AircraftsView:
                AircraftAndTypesView()
            case .AirportsView:
                Text("Apt")
//                AirportsView()
            case .CrewView:
                Text("Crew")
//                CrewView()
            case .SummaryView:
                Text("Summary")
//                SummaryView()
            case .ReportsView:
                Text("Reports")
//                ReportsView()
            case .SettingsView:
                Text("Settings")
//                SettingsView()
            case .AboutView:
                Text("About")
//                AboutView()
        }
    }
}
