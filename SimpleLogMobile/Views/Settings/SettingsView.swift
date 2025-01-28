//
//  SettingsView.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/27/25.
//

import SwiftUI


struct SettingsView: View {
    
    @AppStorage(AppSettings.Keys.autoLockNewEntries) private var lockOnSave: Bool = false
    @State private var selectedMode: InputHour.Mode = AppSettings.hourInputMode
    
    var body: some View {
        VStack(spacing: 20) {
            Toggle(isOn: $lockOnSave) {
                Text("Auto-Lock New Entries")
                    .font(.title2)
            }
            .padding()
            
            Picker("Hour Input Type:", selection: $selectedMode) {
                ForEach(InputHour.Mode.allCases, id: \.self) { mode in
                    Text(mode.description).tag(mode)
                }
            }
            .onChange(of: selectedMode) { oldValue, newValue in
                // Update UserDefaults when selection changes
                AppSettings.hourInputMode = newValue
                print("H")
            }
        }
        .padding()
    }
}
