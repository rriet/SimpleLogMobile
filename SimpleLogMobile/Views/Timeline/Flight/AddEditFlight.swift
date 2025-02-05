//
//  AddEditFlight.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/23/25.
//

import SwiftUI

struct AddEditFlight: View {
    
    // Environment property to dismiss the current view
    @Environment(\.dismiss) var dismiss
    
    private var flightVM = FlightViewModel()
    private var aircraftVM = AircraftViewModel()
    
    var timelineVM: TimelineViewModel
    
    @Binding var flightToEdit: Flight?
    
    @State private var aircraft: Aircraft? = nil
    @State private var dateStart: Date = Date()
    @State private var dateTakeOff: Date = Date()
    @State private var dateLanding: Date = Date()
    @State private var dateEnd: Date = Date()
    @State private var timeBlock: Int16 = 0
    @State private var isLocked: Bool = false
    @State private var takeoffDay: Int16 = 0
    @State private var takeoffNight: Int16 = 0
    @State private var landingDay: Int16 = 0
    @State private var landingNight: Int16 = 0
    @State private var timeFlight: Int16 = 0
    @State private var timeNight: Int16 = 0
    @State private var timeIfr: Int16 = 0
    @State private var timePic: Int16 = 0
    @State private var timeSic: Int16 = 0
    @State private var timePicUs: Int16 = 0
    @State private var timeDual: Int16 = 0
    @State private var timeInstructor: Int16 = 0
    @State private var timeXc: Int16 = 0
    @State private var timeCustom1: Int16 = 0
    @State private var timeCustom2: Int16 = 0
    @State private var timeCustom3: Int16 = 0
    @State private var timeCustom4: Int16 = 0
    @State private var timeSimInst: Int16 = 0
    @State private var approachIfr: Int16 = 0
    @State private var approachType: String = ""
    @State private var remarks: String = ""
    @State private var notes: String = ""
    
    @StateObject var alertManager = AlertManager()
    
    init(_ flight: Binding<Flight?>, timelineVM: TimelineViewModel) {
        self.timelineVM = timelineVM
        self._flightToEdit = flight
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    InputDate(
                        title: "Date",
                        dateStart: $dateStart
                    )
                    
                    DatePicker(
                        "Test",
                        selection: $dateStart,
                        displayedComponents: .hourAndMinute
                    )
                    
                    InputHour(
                        date: $dateStart,
                        mode: AppSettings.hourInputMode,
                        title: "Block Off"
                    )
                    
                    if AppSettings.logTakeOffAndLanding {
                        InputHour(
                            date: $dateTakeOff,
                            mode: AppSettings.hourInputMode,
                            title: "Take Off"
                        )
                        
                        InputHour(
                            date: $dateLanding,
                            mode: AppSettings.hourInputMode,
                            title: "Landing"
                        )
                    }
                    
                    InputHour(
                        date: $dateEnd,
                        mode: AppSettings.hourInputMode,
                        title: "Block In"
                    )
                    
                }
                
                Section(header: Text("")) {
                    HStack{
                        VStack (alignment: .trailing) {
                            Picker("Aircraft:", selection: $aircraft) {
                                Text("Select one").tag(nil as Aircraft?) // Tag for the "none" option
                                ForEach(aircraftVM.aircraftList) { acft in
                                    Text(acft.registration.strUnwrap).tag(acft as Aircraft?)
                                }
                            }
                            
                            if aircraft == nil {
                                Text("Required!")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        Text("Type: \(aircraft?.aircraftType?.designator.strUnwrap ?? "")")
                            .frame(maxWidth: .infinity)
                    }
                    HStack{
                        VStack (alignment: .trailing) {
                            Picker("Aircraft:", selection: $aircraft) {
                                Text("Select one").tag(nil as Aircraft?) // Tag for the "none" option
                                ForEach(aircraftVM.aircraftList) { acft in
                                    Text(acft.registration.strUnwrap).tag(acft as Aircraft?)
                                }
                            }
                            
                            if aircraft == nil {
                                Text("Required!")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        Text("Type: \(aircraft?.aircraftType?.designator.strUnwrap ?? "")")
                            .frame(maxWidth: .infinity)
                    }
                }
                
                Section(header: Text("Takeoff & Landing")) {
                    Stepper("Takeoff Day: \(takeoffDay)", value: $takeoffDay)
                    Stepper("Takeoff Night: \(takeoffNight)", value: $takeoffNight)
                    Stepper("Landing Day: \(landingDay)", value: $landingDay)
                    Stepper("Landing Night: \(landingNight)", value: $landingNight)
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
//                            saveCrew()
                    }
                    .disabled(
//                            isNameInvalid
                        true
                    )
                }
            }
            .onAppear {
                initializeFields()
            }
        }
    }
    
    private func initializeFields() {
        guard let receivedFlight = flightToEdit else { return }
        
        self.dateEnd = receivedFlight.startTimeline?.dateValue ?? .now
        self.dateEnd = receivedFlight.dateEnd ?? .now
        
        
        
        //    @State private var timeBlock: Int16 = 0
        //    @State private var isLocked: Bool = false
        //    @State private var takeoffDay: Int16 = 0
        //    @State private var takeoffNight: Int16 = 0
        //    @State private var landingDay: Int16 = 0
        //    @State private var landingNight: Int16 = 0
        //    @State private var timeFlight: Int16 = 0
        //    @State private var timeNight: Int16 = 0
        //    @State private var timeIfr: Int16 = 0
        //    @State private var timePic: Int16 = 0
        //    @State private var timeSic: Int16 = 0
        //    @State private var timePicUs: Int16 = 0
        //    @State private var timeDual: Int16 = 0
        //    @State private var timeInstructor: Int16 = 0
        //    @State private var timeXc: Int16 = 0
        //    @State private var timeCustom1: Int16 = 0
        //    @State private var timeCustom2: Int16 = 0
        //    @State private var timeCustom3: Int16 = 0
        //    @State private var timeCustom4: Int16 = 0
        //    @State private var timeSimInst: Int16 = 0
        //    @State private var approachIfr: Int16 = 0
        //    @State private var approachType: String = ""
        //    @State private var remarks: String = ""
        //    @State private var notes: String = ""
        
        
    }
    
}
