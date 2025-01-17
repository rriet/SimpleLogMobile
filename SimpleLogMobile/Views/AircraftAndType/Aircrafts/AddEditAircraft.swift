//
//  AddEditAircraft.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/16/25.
//

import SwiftUI

struct AddEditAircraftView: View {
    
    // Environment property to dismiss the current view
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var aircraftTypeVM: AircraftTypeViewModel
    private var aircraftVM = AircraftViewModel()
    
    
    @State private var registration: String = ""
    @State private var isRegistrationInvalid: Bool = false
    @State private var aircraftMtow: String = ""
    @State private var istMtowInvalid: Bool = false
    @State private var isSimulator: Bool = false
    @State private var selectedType: AircraftType?
    @State private var showAddTypeSheet = false
    @State private var isLocked = false
    
    @Binding var aircraftToEdit: Aircraft?
    
    @StateObject var alertManager = AlertManager()
    
    init(_ aircraft: Binding<Aircraft?>) {
        self._aircraftToEdit = aircraft
    }
    
    var body: some View {
        NavigationView {
            Form {
                InputField(
                    "Registration",
                    textValue: $registration,
                    isInvalid: $isRegistrationInvalid,
                    isRequired: true,
                    minLength: 3,
                    capitalization: .characters,
                    customValidation: { input in
                        checkExists(registration: input)
                    }
                )
                NumericField(
                    "MTOW",
                    textValue: $aircraftMtow,
                    isInvalid: $istMtowInvalid,
                    inputType: .positiveInteger
                )
                Toggle("Simulator", isOn: $isSimulator)
                    .onChange(of: isSimulator, changeIsSimulator)
                
                HStack(alignment: .top) {
                    VStack (alignment: .trailing) {
                        Picker("Aircraft Type", selection: $selectedType) {
                            Text("Select one").tag(nil as AircraftType?)
                            ForEach(aircraftTypeVM.typeList) { type in
                                Text(type.designatorUnwrapped).tag(type as AircraftType?)
                            }
                        }
                        
                        if selectedType == nil {
                            Text("Required!")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    Button {
                        selectedType = nil
                        showAddTypeSheet = true
                    } label: {
                        Image(systemName: "plus") // Use an Image
                            .font(.system(size: 20, weight: .bold))
                            .frame(width: 44, height: 20)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveAircraft()
                    }
                    .disabled(
                        isRegistrationInvalid ||
                        istMtowInvalid ||
                        selectedType == nil
                    )
                }
            }
            .navigationTitle(aircraftToEdit == nil ? "Add Aircraft" : "Edit Aircraft")
            .navigationBarTitleDisplayMode(.inline)
            
            .alert(item: $alertManager.currentAlert) { alertInfo in
                alertManager.getAlert(alertInfo)
            }
            .sheet(isPresented: $showAddTypeSheet) {
                AddEditTypeView($selectedType)
            }
            .onAppear {
                initializeFields()
            }
        }
    }
    
    
    private func initializeFields() {
        guard let receivedAircraft = aircraftToEdit else { return }
        
        registration = receivedAircraft.registration.strUnwrap
        aircraftMtow = String(receivedAircraft.aircraftMtow)
        isSimulator = receivedAircraft.isSimulator
        selectedType = receivedAircraft.aircraftType
    }
    
    private func changeIsSimulator() {
        if let aircraft = aircraftToEdit, !aircraft.allowDelete {
            // Revert to old value
            isSimulator = aircraft.isSimulator
            
            alertManager.showAlert(.simple(
                title: "Alert",
                message: "The selected value cannot be changed because the Aircraft is associated with flights or Simulator Sessions."
            ))
            return
        }
    }
    
    private func saveAircraft() {
        
        if let typeUnwraped = selectedType {
            do {
                if aircraftToEdit == nil {
                    // Adding a new aircraft type
                    try aircraftVM
                        .addAircraft(
                            registration: registration,
                            aircraftMtow: aircraftMtow,
                            aircraftType: typeUnwraped,
                            isSimulator: isSimulator,
                            isLocked: false
                        )
                } else {
                    // Editing an existing aircraft type
                    try aircraftVM.editAircraft(
                        aircraftToEdit: aircraftToEdit!, // Safe force-unwrapping as it's checked earlier
                        registration: registration,
                        aircraftMtow: aircraftMtow,
                        aircraftType: typeUnwraped,
                        isSimulator: isSimulator,
                        isLocked: false
                    )
                }
                try aircraftVM.fetchAircraftData()
                try aircraftTypeVM.fetchTypeData()
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
        }
        // Dismiss the view after a successful save
        dismiss()
    }
    
    private func checkExists(registration: String) -> InputField.ErrorType? {
        
        // if Type is not nil, User is editing an existing Aircraft.
        // Skip duplicate check only if the Registration is the same as the original Registration.
        if let acft = aircraftToEdit, acft.registration.strUnwrap.uppercased() == registration.uppercased() {
            return nil
        }
        
        do {
            if try aircraftVM.checkExist(registration) {
                // Return the error type if duplicate found
                return .invalidFormat("This Aircraft Registration already exists.")
            } else {
                return nil
            }
        } catch {
            return .invalidFormat("There was an unknown error reading from database.")
        }
    }
}
