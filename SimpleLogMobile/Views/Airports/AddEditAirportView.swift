//
//  AddEditAirportView.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/19/25.
//

import SwiftUI

struct AddEditAirportView: View {
    
    // Environment property to dismiss the current view
    @Environment(\.dismiss) var dismiss
    
    var airportVM: AirportViewModel
    
    @Binding var airportToEdit: Airport?
    
    @State private var icao: String = ""
    @State private var isIcaoInvalid: Bool = false
    @State private var iata: String = ""
    @State private var name: String = ""
    @State private var city: String = ""
    @State private var country: String = ""
    @State private var latitude: Double = 0
    @State private var longitude: Double = 0
    @State private var isFavorite: Bool = false
    
    @StateObject var alertManager = AlertManager()
    
    @State private var showMapPickerView: Bool = false
    
    let onSave: () -> Void
    
    init(_ airport: Binding<Airport?>, airportVM: AirportViewModel, onSave: @escaping () -> Void) {
        self.airportVM = airportVM
        self._airportToEdit = airport
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            Form {
                InputField(
                    "ICAO",
                    textValue: $icao,
                    isInvalid: $isIcaoInvalid,
                    isRequired: true,
                    minLength: 3,
                    capitalization: .characters,
                    customValidation: { input in
                        checkExists(icao: input)
                    }
                )
                
                InputField(
                    "IATA",
                    textValue: $iata,
                    capitalization: .characters
                )
                
                InputField(
                    "Name",
                    textValue: $name,
                    capitalization: .words
                )
                
                InputField(
                    "City",
                    textValue: $city,
                    capitalization: .words
                )
                
                InputField(
                    "Country",
                    textValue: $country,
                    capitalization: .words
                )
                
                Toggle(isOn: $isFavorite) {
                    Text("Favorite")
                        .font(.title2)
                }
                
                HStack {
                    VStack(alignment: .trailing) {
                        Text("Latitude:")
                        Text("Longitude:")
                    }
                    .font(.caption)
                    VStack(alignment: .leading) {
                        Text("\(latitude.stringFromLatitude())")
                        Text("\(longitude.stringFromLongitude())")
                    }
                    .font(.caption)
                    
                    Spacer()
                    
                    Button("Select Location") {
                        showMapPickerView = true
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(
                        Color.blue
                            .cornerRadius(10)
                            .shadow(radius: 10))
                }
                .frame(maxWidth: .infinity)
                
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveAirport()
                    }
                    .disabled(
                        isIcaoInvalid
                    )
                }
            }
            .navigationTitle(
                airportToEdit == nil ? "Add Airport" : "Edit Airport"
            )
            .navigationBarTitleDisplayMode(.inline)
            
            .alert(item: $alertManager.currentAlert) { alertInfo in
                alertManager.getAlert(alertInfo)
            }
            .sheet(isPresented: $showMapPickerView) {
                MapPickerView(
                    latitude: $latitude,
                    longitude: $longitude
                )
            }
            .onAppear {
                initializeFields()
            }
        }
    }
    
    
    private func initializeFields() {
        guard let receivedAirport = airportToEdit else { return }
        
        icao = receivedAirport.icao.strUnwrap
        iata = receivedAirport.iata.strUnwrap
        name = receivedAirport.name.strUnwrap
        city = receivedAirport.city.strUnwrap
        country = receivedAirport.country.strUnwrap
        latitude = receivedAirport.latitude
        longitude = receivedAirport.longitude
        isFavorite = receivedAirport.isFavorite
    }
    
    private func saveAirport() {

        do {
            var newAirport: Airport!
            
            if airportToEdit == nil {
                // Adding a new aircraft Airport
                newAirport = try airportVM
                    .addAirport(
                        icao: icao,
                        iata: iata,
                        name: name,
                        city: city,
                        country: country,
                        latitude: latitude,
                        longitude: longitude,
                        isFavorite: isFavorite
                    )
            } else {
                // Editing an existing Airport
                try airportVM
                    .editAirport(
                        airportToEdit!,
                        icao: icao,
                        iata: iata,
                        name: name,
                        city: city,
                        country: country,
                        latitude: latitude,
                        longitude: longitude,
                        isFavorite: isFavorite
                    )
            }
            if let newAirport = newAirport {
                airportToEdit = newAirport
            }
            onSave()
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
        
        // Dismiss the view after a successful save
        dismiss()
    }
    
    private func checkExists(icao: String) -> InputField.ErrorType? {
        
        // if Type is not nil, User is editing an existing Airport.
        // Skip duplicate check only if the ICAO is the same as the original ICAO.
        if let apt = airportToEdit, apt.icao.strUnwrap.uppercased() == icao.uppercased() {
            return nil
        }
        
        do {
            if try airportVM.checkExist(icao) {
                // Return the error type if duplicate found
                return .invalidFormat("This Airport ICAO already exists.")
            } else {
                return nil
            }
        } catch {
            return .invalidFormat("There was an unknown error reading from database.")
        }
    }
}
