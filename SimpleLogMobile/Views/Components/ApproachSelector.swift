//
//  ApproachSelector.swift
//  SimpleLogMobile
//
//  Created by Ricardo Riet Correa on 02/04/2025.
//

import SwiftUI

struct ApproachSelector: View {
    
    @Binding var approachType: String
    
    @State private var showApproachPicker = false
    @State private var newApproach = ""
    let approachTypes = ["ILS", "GLS", "PAR", "VOR", "NDB", "LOC", "LNAV", "SDF", "LDA", "LP", "LPV", "LNAV/VNAV", "LDA"]
    
    var body: some View {
        HStack {
            Text("Type")
            TextField("Approach type", text: $approachType)
            Button {
                showApproachPicker.toggle()
            } label: {
                Image(systemName: "chevron.down")
                    .font(.system(size: 20, weight: .bold))
                    .frame(width: 44, height: 20)
            }
            .buttonStyle(.bordered)
            .popover(isPresented: $showApproachPicker) {
                NavigationStack {
                    VStack(spacing: 16) {
                        Picker("Approach Type", selection: $newApproach) {
                            Text("Select One").tag("")
                            ForEach(approachTypes, id: \.self) { approachType in
                                Text(approachType).tag(approachType)
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                    .navigationBarTitle("Approach Type")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showApproachPicker.toggle()
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                if !newApproach.isEmpty {
                                    approachType = newApproach
                                }
                                showApproachPicker.toggle()
                            }
                        }
                    }
                }
                .presentationDetents([.medium])
            }
            
        }
        
    }
    
}
