//
//  ManuItemModel.swift
//  SimpleLog
//
//  Created by Ricardo Brito Riet Correa on 12/22/24.
//

import Foundation

struct MenuItem: Identifiable {
    let id = UUID()
    let sectionName: String
    let label: String
    let icon: String
    let destination: MenuLink
}
