//
//  MainView.swift
//  SimpleLog
//
//  Created by Ricardo Brito Riet Correa on 1/10/25.
//

import SwiftUI
import CoreData

struct MainView: View {
    
    // MARK: Declarations
    
    @State private var columnVisibility: NavigationSplitViewVisibility = .automatic
    @State private var preferredColumn: NavigationSplitViewColumn = .detail
    @State private var selectedView: MenuLink = .LogbookView
    
    // MARK: Main View
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility, preferredCompactColumn: $preferredColumn) {
            VStack {
                Text("SimpleLog")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)
                
                MenuView(
                    preferredColumn: $preferredColumn,
                    columnVisibility: $columnVisibility,
                    selectedView: $selectedView
                )
            }
            .padding(.all)
            .frame(maxHeight: .infinity, alignment: .top)
            .background(Color.theme.background)
            .navigationTitle("Menu")
            .navigationBarHidden(true)
            
        } detail: {
            SelectedMenuView(selectedView: $selectedView)
        }
    }
}

//#Preview {
//    MainView()
//}
