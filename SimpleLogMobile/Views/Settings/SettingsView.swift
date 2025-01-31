//
//  SettingsView.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/27/25.
//

import SwiftUI


struct SettingsView: View {
    
    @AppStorage(AppSettings.Keys.autoLockNewEntries) private var lockOnSave: Bool = false
    @AppStorage(AppSettings.Keys.logTakeOffAndLanding) private var logTakeOffAndLanding: Bool = false
    @AppStorage(AppSettings.Keys.hourInputMode) private var hourInputMode: InputHour.Mode = InputHour.Mode.text
    
    
    var body: some View {
        VStack(spacing: 20) {
            Toggle(isOn: $lockOnSave) {
                Text("Auto-Lock New Entries")
            }
            .padding()
            
            Toggle(isOn: $logTakeOffAndLanding) {
                Text("Log Take Off and Landing Time")
            }
            .padding()
            
            HStack {
                Text("Hour input field format")
                Spacer()
                Picker("Hour Input Type:", selection: $hourInputMode) {
                    ForEach(InputHour.Mode.allCases, id: \.self) { mode in
                        Text(mode.description).tag(mode)
                    }
                }
            }
        }
        .padding()
    }
}
