//
//  MenuItems.swift
//  SimpleLog
//
//  Created by Ricardo Brito Riet Correa on 12/20/24.
//

import SwiftUI

struct MenuView: View {
    
    @Binding var preferredColumn: NavigationSplitViewColumn
    @Binding var columnVisibility: NavigationSplitViewVisibility
    @State var selectedMenuItem = "Logbook"
    @Binding var selectedView: MenuLink
    
    // Get menu items
    let menu = MenuItems()
    
    // MARK: Main View
    var body: some View {
        ForEach(menu, id: \.0) { (section, items) in
            Text(section)
                .fontWeight(.bold)
                .padding(.top)
            ForEach(items) { item in
                Button {
                    selectedMenuItem = item.label
                    selectedView = item.destination
                    preferredColumn = .detail
                } label: {
                    HStack {
                        Text(item.icon)
                            .font(.title2)
                            .padding(EdgeInsets(top: 3, leading: 10, bottom: 3, trailing: 10))
                        Text(item.label)
                            .fontWeight(selectedMenuItem == item.label ? .black : .light)
                            .animation(.easeIn)
                            .font(.title3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .buttonStyle(.bordered)
            }
            
        }
        .listStyle(.sidebar)
#if os(iOS)
        /// Closes the iPad menu if the tablet is in Portrait
        .onChange(of: selectedMenuItem) {
            if UIDevice.current.userInterfaceIdiom == .pad,
               UIScreen.main.bounds.size.width < UIScreen.main.bounds.size.height {
                columnVisibility = .detailOnly
            }
        }
        // Open iPad menu in case of rotation to portrait
        .onChange(of: UIScreen.main.bounds.size.width) {
            if UIDevice.current.userInterfaceIdiom == .pad,
               UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height {
                columnVisibility = .automatic
            }
        }
#endif
    }
}
