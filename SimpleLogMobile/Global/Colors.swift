//
//  Colors.swift
//  SimpleLog
//
//  Created by Ricardo Brito Riet Correa on 1/11/25.
//

import SwiftUI

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    
    let accent = Color("AccentColor")
    let background = Color("BackgroundColor")
    let foreground = Color("ForegroundColor")
    let secondaryBackground = Color("SecondaryBackgroundColor")
    let secondaryForeground = Color("SecondaryForegroundColor")
    let inactive = Color("Inactive")
    
}
