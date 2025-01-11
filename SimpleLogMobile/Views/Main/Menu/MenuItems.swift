//
//  MenuItems.swift
//  SimpleLog
//
//  Created by Ricardo Brito Riet Correa on 12/22/24.
//

import Foundation

enum MenuLink {
    case LogbookView,
         AircraftsView,
         AirportsView,
         CrewView,
         SummaryView,
         ReportsView,
         SettingsView,
         AboutView
}

func MenuItems() -> [(String, [MenuItem])] {
    
    let mainMenu:[MenuItem] = [
        MenuItem(
            sectionName: "",
            label: "Logbook",
            icon: "📒",
            destination: .LogbookView
        ),
        MenuItem(
            sectionName: "",
            label: "Aircrafts",
            icon: "✈️",
            destination: .AircraftsView
        ),
        MenuItem(
            sectionName: "",
            label: "Airports",
            icon: "📍",
            destination: .AirportsView
        ),
        MenuItem(
            sectionName: "",
            label: "Crew",
            icon: "👨🏼‍✈️",
            destination: .CrewView
        ),
        MenuItem(
            sectionName: "Reports",
            label: "Summary",
            icon: "📄",
            destination: .SummaryView
        ),
        MenuItem(
            sectionName: "Reports",
            label: "Reports",
            icon: "🖨️",
            destination: .ReportsView
        ),
        MenuItem(
            sectionName: "System",
            label: "Settings",
            icon: "⚙️",
            destination: .SettingsView
        ),
        MenuItem(
            sectionName: "System",
            label: "About",
            icon: "💡",
            destination: .AboutView
        )
    ]
    
    // Group by Section and return ordered by Array Key
    let grouped = Dictionary(grouping: mainMenu, by: { $0.sectionName })
    return grouped.sorted(by: { $0.key < $1.key })
}
