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
                TimelineView()
            case .AircraftsView:
                AircraftAndTypesView()
            case .AirportsView:
                AirportsView()
            case .CrewView:
                CrewsView()
            case .SummaryView:
                Text("Summary")
//                SummaryView()
            case .ReportsView:
                Text("Reports")
//                ReportsView()
            case .SettingsView:
                Text("Settings")
                SettingsView()
            case .AboutView:
                Text("About")
//                AboutView()
        }
    }
}
