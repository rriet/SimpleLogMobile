//
//  AddEditType.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/14/25.
//

import SwiftUI

// View for adding or editing an aircraft type
struct AddEditTypeView: View {
    
    // Environment property to dismiss the current view
    @Environment(\.dismiss) var dismiss
    
    // EnvironmentObject for accessing the shared AircraftTypeViewModel
    @EnvironmentObject var aircraftTypeVM: AircraftTypeViewModel
    
    // State variables to bind form inputs and track validation states
    @State private var designator: String = ""
    @State private var isDesignatorInvalid: Bool = false
    @State private var family: String = ""
    @State private var maker: String = ""
    @State private var mtow: String = "0"
    @State private var isMotwInvalid: Bool = false
    @State private var aircraftCategory: AircraftCategory = .Landplane
    @State private var engineType: EngineTypes = .Jet
    @State private var multiEngine: Bool = true
    @State private var multiPilot: Bool = true
    @State private var efis: Bool = true
    @State private var complex: Bool = true
    @State private var highPerformance: Bool = true
    
    // Binding to the type being edited (if any)
    @Binding var typeToEdit: AircraftType?
    
    // StateObject to manage alert presentation
    @StateObject var alertManager = AlertManager()
    
    // Custom initializer to pass the typeToEdit binding
    init(_ aircraftType: Binding<AircraftType?>) {
        self._typeToEdit = aircraftType
    }
    
    // Main body of the view
    var body: some View {
        NavigationView {
            Form {
                InputField(
                    "Designator",
                    textValue: $designator,
                    isInvalid: $isDesignatorInvalid,
                    isRequired: true,
                    minLength: 3,
                    capitalization: .characters,
                    customValidation: { input in
                        checkExists(input)
                    }
                )
                
                InputField(
                    "Family",
                    textValue: $family,
                    capitalization: .sentences
                )
                
                InputField(
                    "Maker",
                    textValue: $maker,
                    capitalization: .sentences
                )
                
                // TextField for Maximum Take-Off Weight (MTOW)
                TextField("MTOW", text: $mtow)
                    .keyboardType(.numberPad) // Ensure numeric input
                
                NumericField(
                    "MTOW",
                    textValue: $mtow,
                    isInvalid: $isMotwInvalid,
                    isRequired: true,
                    inputType: .positiveInteger
                )
                
                // Picker for Aircraft Class
                Picker("Aircraft Class", selection: $aircraftCategory) {
                    ForEach(AircraftCategory.allCases, id: \.self) { value in
                        Text(value.rawValue).tag(value)
                    }
                }
                
                // Picker for Engine Type
                Picker("Engine Type", selection: $engineType) {
                    ForEach(EngineTypes.allCases, id: \.self) { value in
                        Text(value.rawValue).tag(value)
                    }
                }
                
                // Toggles for various aircraft properties
                Toggle("Multi-Engine", isOn: $multiEngine)
                Toggle("Multi-Pilot", isOn: $multiPilot)
                Toggle("EFIS", isOn: $efis)
                Toggle("Complex", isOn: $complex)
                Toggle("High Performance", isOn: $highPerformance)
            }
            .navigationTitle(typeToEdit == nil ? "Add Aircraft Type" : "Edit Aircraft Type") // Dynamic title
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Cancel button
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss() // Dismiss the view
                    }
                }
                // Save button
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveType() // Save the aircraft type changes
                    }
                    .disabled(isDesignatorInvalid || isMotwInvalid)
                }
            }
        }
        .onAppear { initializeFields() } // Initialize form fields if editing
        .alert(item: $alertManager.currentAlert) { alertInfo in
            alertManager.getAlert(alertInfo) // Show alerts for errors or confirmations
        }
    }
    
    private func checkExists(_ input: String) -> InputField.ErrorType?  {
        
        // if Type is not nil, User is editing an existing Type.
        // Skip duplicate check only if the Type Designator is the same as the original Designator.
        if let acftType = typeToEdit, acftType.designator.strUnwrap.uppercased() == input.uppercased() {
            return nil
        }
        
        do {
            if try aircraftTypeVM.checkExist(input) {
                // Return the error type if duplicate found
                return .invalidFormat("This Aircraft Type already exists.")
            } else {
                return nil
            }
        } catch {
            return .invalidFormat("There was an unknown error reading from database.")
        }
    }
    
    // Initialize form fields with the values of the type being edited
    private func initializeFields() {
        guard let receivedType = typeToEdit else { return }
        
        // Populate fields with existing data
        self.designator = receivedType.designator.strUnwrap
        self.family = receivedType.family.strUnwrap
        self.maker = receivedType.maker.strUnwrap
        self.aircraftCategory = receivedType.category
        self.engineType = receivedType.engine
        self.mtow = String(receivedType.mtow)
        self.multiEngine = receivedType.multiEngine
        self.multiPilot = receivedType.multiPilot
        self.efis = receivedType.efis
        self.complex = receivedType.complex
        self.highPerformance = receivedType.highPerformance
    }
    
    // Save the aircraft type (add new or edit existing)
    private func saveType() {
        do {
            if typeToEdit == nil {
                // Adding a new aircraft type
                try aircraftTypeVM.addType(
                    designator: designator,
                    family: family,
                    maker: maker,
                    aircraftCategory: aircraftCategory,
                    engineType: engineType,
                    mtow: mtow,
                    multiEngine: multiEngine,
                    multiPilot: multiPilot,
                    efis: efis,
                    complex: complex,
                    highPerformance: highPerformance
                )
            } else {
                // Editing an existing aircraft type
                try aircraftTypeVM.editType(
                    typeToEdit: typeToEdit!, // Safe force-unwrapping as it's checked earlier
                    designator: designator,
                    family: family,
                    maker: maker,
                    aircraftCategory: aircraftCategory,
                    engineType: engineType,
                    mtow: mtow,
                    multiEngine: multiEngine,
                    multiPilot: multiPilot,
                    efis: efis,
                    complex: complex,
                    highPerformance: highPerformance
                )
            }
        } catch let details as ErrorDetails {
            // Handle specific error details
            alertManager.showAlert(.error(details: details))
            return
        } catch {
            // Handle unexpected errors
            alertManager.showAlert(.simple(
                title: "Unexpected Error",
                message: error.localizedDescription
            ))
            return
        }
        
        dismiss() // Dismiss the view after a successful save
    }
}
