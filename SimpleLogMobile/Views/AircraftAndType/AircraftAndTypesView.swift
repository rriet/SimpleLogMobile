//
//  AircraftAndTypesView.swift
//  SimpleLog
//
//  Created by Ricardo Brito Riet Correa on 1/10/25.
//

import SwiftUI

struct AircraftAndTypesView: View {
    @State var selectedView: String = "Types"
    
    
    var body: some View {
        ViewThatFits {
            HStack {
                VStack {
                    Text("Types")
                        .font(.largeTitle)
                        .padding(.vertical, 1)
                    TypesView()
                }
                .frame(minWidth: 300, maxWidth: .infinity)
                VStack {
                    Text("Aircrafts")
                        .font(.largeTitle)
                        .padding(.vertical, 1)
                    AircraftsView()
                }
                .frame(minWidth: 300, maxWidth: .infinity)
            }
            VStack {
                // Picker for selecting the view
                Picker(
                    selection: $selectedView, // Bind to the selectedView state
                    label: Text("Select View") // Label for the Picker
                ) {
                    Text("Types").tag("Types") // Option for Types
                    Text("Aircrafts").tag("Aircrafts") // Option for Aircrafts
                }
                .pickerStyle(SegmentedPickerStyle()) // Optionally, you can change the style
                
                // Conditionally render views based on the selectedView
                if selectedView == "Types" {
                    // Render the Types view
                    TypesView()
                } else if selectedView == "Aircrafts" {
                    // Render the Aircrafts view
                    AircraftsView()
                }
            }
            .frame(maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(Color.theme.secondaryBackground))
    }
}

//#Preview {
//    AircraftAndTypesView()
//}
