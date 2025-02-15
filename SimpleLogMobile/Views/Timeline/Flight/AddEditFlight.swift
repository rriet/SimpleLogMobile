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
    @State private var airportDep: Airport? = nil
    @State private var airportArr: Airport? = nil
    @State private var dateStart: Date = Date()
    @State private var dateTakeOff: Date = Date()
    @State private var dateLanding: Date = Date()
    @State private var dateEnd: Date = Date()
    @State private var timeBlock: Int16 = 0
    @State private var isLocked: Bool = false
    @State private var pfTakeOff: Bool = false
    @State private var pfLanding: Bool = false
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
    
    @State private var count: Int16 = 5
    @State private var showCrewDropdown: Bool = false
    
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
                    HStack {
                        AirportInputLine(airport: $airportDep)
                        Button {
                            showCrewDropdown.toggle()
                        } label: {
                            HStack {
                                Text("Crew")
                                Image(systemName: showCrewDropdown ? "chevron.up" : "chevron.down")
                                    .font(.system(size: 15, weight: .bold))
                                    .animation(nil, value: showCrewDropdown)
                            }
                            
                                .frame(width: 80, height: 20)
                                .overlay(
                                    ZStack {
                                        if count > 0 {
                                            Text("\(count)")
                                                .font(.caption)
                                                .foregroundColor(.white)
                                                .padding(6)
                                                .background(Color.red)
                                                .clipShape(Circle())
                                                .offset(x: 17, y: -15)
                                        }
                                    },
                                        alignment: .topTrailing
                                )
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    if showCrewDropdown {
                        VStack {
                            Button {
                                showCrewDropdown.toggle()
                            } label: {
                                Text("Add Crew Member")
                            }
                            .buttonStyle(.bordered)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            
                            Grid(alignment: .centerFirstTextBaseline,
                                 horizontalSpacing: 1,
                                 verticalSpacing: 5) {
                                GridRow {
                                    Text("Fernando Brito Riet Correa (RBRI)")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .minimumScaleFactor(0.8)
                                    Text("Captain")
                                        .font(.caption)
                                    Button {
                                        showCrewDropdown.toggle()
                                    } label: {
                                        Image(systemName: "person.badge.minus")
                                            .font(.system(size: 15, weight: .bold))
                                    }
                                    .padding(6)
                                    .buttonStyle(.bordered)
                                    .foregroundColor(.red)
                                }
                                
                                GridRow {
                                    Text("Self")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text("First Officer")
                                        .font(.caption)
                                    Button {
                                        showCrewDropdown.toggle()
                                    } label: {
                                        Image(systemName: "person.badge.minus")
                                            .font(.system(size: 15, weight: .bold))
                                    }
                                    .padding(6)
                                    .buttonStyle(.bordered)
                                    .foregroundColor(.red)
                                }
                                
                                GridRow {
                                    Text("Rafael Mendez")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text("Line instructor")
                                        .font(.caption)
                                    Button {
                                        showCrewDropdown.toggle()
                                    } label: {
                                        Image(systemName: "person.badge.minus")
                                            .font(.system(size: 15, weight: .bold))
                                    }
                                    .padding(6)
                                    .buttonStyle(.bordered)
                                    .foregroundColor(.red)
                                }
                                
                            }
                                 .font(.headline)
                                 .lineLimit(1)
                            
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 15, leading: 10, bottom: 15, trailing: 10))
                
                Section ("Departure") {
                    VStack(alignment: .leading, spacing: 5) {
                        
                        AirportInputLine(airport: $airportDep)
                        
                        HStack{
                            InputHour(
                                date: $dateStart,
                                mode: AppSettings.hourInputMode,
                                title: "Block Off"
                            )
                            
                            if AppSettings.logTakeOffAndLanding {
                                Spacer()
                                InputHour(
                                    date: $dateTakeOff,
                                    mode: AppSettings.hourInputMode,
                                    title: "Take Off"
                                )
                            } else {
                                Toggle(isOn: $pfTakeOff) {
                                    Text("Pilot Flying")
                                }
                                .padding(.leading, 30)
                            }
                        }
                        
                        if AppSettings.logTakeOffAndLanding {
                            Toggle(isOn: $pfTakeOff) {
                                Text("Pilot Flying")
                            }
                            .frame(width: 160)
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 15, leading: 10, bottom: 15, trailing: 10))
                    
                Section("Arrival") {
                    VStack(alignment: .leading, spacing: 5) {
                        AirportInputLine(airport: $airportArr)
                        
                        HStack {
                            if AppSettings.logTakeOffAndLanding {
                                InputHour(
                                    date: $dateLanding,
                                    mode: AppSettings.hourInputMode,
                                    title: "Landing"
                                )
                                Spacer()
                            }
                            
                            InputHour(
                                date: $dateEnd,
                                mode: AppSettings.hourInputMode,
                                title: "Block In"
                            )
                            
                            if !AppSettings.logTakeOffAndLanding {
                                Toggle(isOn: $pfLanding) {
                                    Text("Pilot Flying")
                                }
                                .padding(.leading, 30)
                            }
                        }
                        if AppSettings.logTakeOffAndLanding {
                            Toggle(isOn: $pfLanding) {
                                Text("Pilot Flying")
                            }
                            .frame(width: 160)
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 15, leading: 10, bottom: 15, trailing: 10))
                
//                Section {
//                    HStack{
//                        VStack (alignment: .trailing) {
//                            Picker("Aircraft:", selection: $aircraft) {
//                                Text("Select one").tag(nil as Aircraft?) // Tag for the "none" option
//                                ForEach(aircraftVM.aircraftList) { acft in
//                                    Text(acft.registration.strUnwrap).tag(acft as Aircraft?)
//                                }
//                            }
//                            
//                            if aircraft == nil {
//                                Text("Required!")
//                                    .font(.caption)
//                                    .foregroundColor(.red)
//                            }
//                        }
//                        Text("Type: \(aircraft?.aircraftType?.designator.strUnwrap ?? "")")
//                            .frame(maxWidth: .infinity)
//                    }
//                    HStack{
//                        VStack (alignment: .trailing) {
//                            Picker("Aircraft:", selection: $aircraft) {
//                                Text("Select one").tag(nil as Aircraft?) // Tag for the "none" option
//                                ForEach(aircraftVM.aircraftList) { acft in
//                                    Text(acft.registration.strUnwrap).tag(acft as Aircraft?)
//                                }
//                            }
//                            
//                            if aircraft == nil {
//                                Text("Required!")
//                                    .font(.caption)
//                                    .foregroundColor(.red)
//                            }
//                        }
//                        Text("Type: \(aircraft?.aircraftType?.designator.strUnwrap ?? "")")
//                            .frame(maxWidth: .infinity)
//                    }
//                }
//                
//                Section(header: Text("Takeoff & Landing")) {
//                    Stepper("Takeoff Day: \(takeoffDay)", value: $takeoffDay)
//                    Stepper("Takeoff Night: \(takeoffNight)", value: $takeoffNight)
//                    Stepper("Landing Day: \(landingDay)", value: $landingDay)
//                    Stepper("Landing Night: \(landingNight)", value: $landingNight)
//                }
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
