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
#if os(macOS)
            // MacOs - This prevent the user to change size of menu bar, but alow to hide/show
            .navigationSplitViewColumnWidth(min: 200, ideal: 200, max: 200)
#else
            .navigationTitle("Menu")
            .navigationBarHidden(true)
#endif
            
        } detail: {
            SelectedMenuView(selectedView: $selectedView)
        }
    }
}

//#Preview {
//    MainView()
//}
