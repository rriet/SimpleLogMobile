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
    
    // Binding to the type being edited (if any)
    @Binding var typeToEdit: AircraftType?
    @State private var families: [String] = []
    
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
    
    // StateObject to manage alert presentation
    @StateObject var alertManager = AlertManager()
    @State private var showFamilyPicker: Bool = false
    
    // Custom initializer to pass the typeToEdit binding
    init(_ aircraftType: Binding<AircraftType?>, onTypeAdded: ((AircraftType) -> Void)? = nil) {
        self._typeToEdit = aircraftType
    }
    
    // Main body of the view
    var body: some View {
        NavigationStack {
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
                
                HStack{
                    InputField(
                        "Family",
                        textValue: $family,
                        capitalization: .sentences
                    )
                    Button {
                        showFamilyPicker.toggle()
                    } label: {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 20, weight: .bold))
                            .frame(width: 44, height: 20)
                    }
                    .buttonStyle(.bordered)
                    .disabled(families.isEmpty)
                }
                
                
                InputField(
                    "Maker",
                    textValue: $maker,
                    capitalization: .sentences
                )
                
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
                Toggle("EFIS", isOn: $efis)
                Toggle("Complex", isOn: $complex)
                Toggle("High Performance", isOn: $highPerformance)
                Toggle("Multi-Pilot", isOn: $multiPilot)
                Toggle("Multi-Engine", isOn: $multiEngine)
            }
            .navigationTitle(typeToEdit == nil ? "Add Aircraft Type" : "Edit Aircraft Type")
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
        .sheet(isPresented: $showFamilyPicker) {
            FamilySelector(family: $family)
                .presentationDetents([.medium])
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
        
        // Load existing Type Families
        try? families = aircraftTypeVM.fetchFamilyList()
        
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
                let newType = try aircraftTypeVM.addType(
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
                typeToEdit = newType
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
        try! aircraftTypeVM.fetchTypeList()
        // Dismiss the view after a successful save
        dismiss()
    }
}


struct FamilySelector: View {
    
    // Environment property to dismiss the current view
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var aircraftTypeVM: AircraftTypeViewModel
    
    @Binding var family: String
    
    @State private var families: [String] = []
    @State var newFamily: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Picker("Families", selection: $newFamily) {
                    Text("Select One").tag("")
                    ForEach(families, id: \.self) { familyName in
                        Text(familyName).tag(familyName)
                    }
                }
                .pickerStyle(.wheel)
            }
            .navigationBarTitle("Select a Family")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        if !newFamily.isEmpty {
                            family = newFamily
                        }
                        dismiss()
                    }
                }
            }
        }
        .onAppear() {
            try? families = aircraftTypeVM.fetchFamilyList()
            
            if families.contains(family) {
                newFamily = family
            } else {
                newFamily = ""
            }
        }
    }
}
