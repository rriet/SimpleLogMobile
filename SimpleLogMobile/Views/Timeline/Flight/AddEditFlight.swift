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
    private var timelineVM: TimelineViewModel
    
    @Binding var flightToEdit: Flight?
    
    @State private var aircraft: Aircraft? = nil
    @State private var airportDep: Airport? = nil
    @State private var airportArr: Airport? = nil
    @State private var dateStart: Date = Date()
    @State private var dateTakeOff: Date = Date()
    @State private var dateLanding: Date = Date()
    @State private var dateEnd: Date = Date()
    @State private var timeBlock: Int = 0
    @State private var isLocked: Bool = false
    @State private var pfTakeOff: Bool = false
    @State private var pfLanding: Bool = false
    @State private var takeoffDay: Int = 0
    @State private var takeoffNight: Int = 0
    @State private var landingDay: Int = 0
    @State private var landingNight: Int = 0
    @State private var timeFlight: Int = 0
    @State private var timeNight: Int = 0
    @State private var timeIfr: Int = 0
    @State private var timePic: Int = 0
    @State private var timeSic: Int = 0
    @State private var timePicUs: Int = 0
    @State private var timeDual: Int = 0
    @State private var timeInstructor: Int = 0
    @State private var timeXc: Int = 0
    @State private var timeCustom1: Int = 0
    @State private var timeCustom2: Int = 0
    @State private var timeCustom3: Int = 0
    @State private var timeCustom4: Int = 0
    @State private var timeSimInst: Int = 0
    @State private var approachIfr: Int = 0
    @State private var approachType: String = ""
    @State private var remarks: String = ""
    @State private var notes: String = ""
    @State var crewList: [Crew: CrewPosition] = [:]
    @State private var showCrewDropdown: Bool = false
    
    @StateObject var alertManager = AlertManager()
    
    private var count: Int {
        crewList.count
    }
    
    init(
        _ flight: Binding<Flight?>,
        timelineVM: TimelineViewModel
    ) {
        self._flightToEdit = flight
        self.timelineVM = timelineVM
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section("Flight") {
                    InputDate(title: "Date", dateStart: $dateStart)
                    HStack {
                        AircraftInputLine(aircraft: $aircraft)
                        Button {
                            showCrewDropdown
                                .toggle()
                        } label: {
                            HStack {
                                Text(
                                    "Crew"
                                )
                                Image(systemName: showCrewDropdown ? "chevron.up" : "chevron.down")
                                .font(.system(size: 15,weight: .bold))
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
                                Text("Select Crew")
                            }
                            .buttonStyle(.bordered)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            
                            Grid(
                                alignment: .centerFirstTextBaseline,
                                horizontalSpacing: 8,
                                verticalSpacing: 5
                            ) {
                                let crewArray = Array(crewList.keys)
                                ForEach(crewArray, id: \.objectID) { crew in
                                    GridRow {
                                        Text(crew.name ?? "")
                                            .font(.subheadline)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .minimumScaleFactor(0.8)
                                        Text("\(crewList[crew]?.rawValue ?? "")")
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
                            }
                            .font(.headline)
                            .lineLimit(1)
                        }
                    }
                    VStack(alignment: .leading) {
                        AirportInputLine(airport: $airportDep, label: "From")
                        
                        HStack {
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
                            }
                            
                            if !AppSettings.logTakeOffAndLanding
                                || UIDevice.current.userInterfaceIdiom == .pad {
                                Toggle(isOn: $pfTakeOff) {
                                    Text("Pilot Flying")
                                }
                                .padding(.leading,30)
                                .frame(width: 180)
                            }
                        }
                        
                        if AppSettings.logTakeOffAndLanding
                            && UIDevice.current.userInterfaceIdiom != .pad {
                            Toggle(isOn: $pfTakeOff) {
                                Text("Pilot Flying")
                            }
                            .frame(width: 160)
                        }
                    }
                    VStack(alignment: .leading) {
                        AirportInputLine(airport: $airportArr, label: "To")
                        
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
                            
                            if !AppSettings.logTakeOffAndLanding
                                || UIDevice.current.userInterfaceIdiom == .pad{
                                Toggle(isOn: $pfLanding) {
                                    Text("Pilot Flying")
                                }
                                .padding(.leading, 30)
                                .frame(width: 180)
                            }
                        }
                        if AppSettings.logTakeOffAndLanding
                            && UIDevice.current.userInterfaceIdiom != .pad {
                            Toggle(isOn: $pfLanding) {
                                Text("Pilot Flying")
                            }
                            .frame(width: 160)
                        }
                        
                        Button {
                            //                        onTapGesture()
                        } label: {
                            Text("Calculate")
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .listSectionSpacing(.compact)
                
                Section {
                    VStack {
                        Text("Takeoff")
                        .foregroundStyle(Color.theme.secondaryForeground)
                        HStack {
                            NumericStepper("Day", value: $takeoffDay, minValue: 0)
                            NumericStepper("Night", value: $takeoffNight, minValue: 0)
                        }
                    }
                    VStack {
                        Text("Landings")
                        .foregroundStyle(Color.theme.secondaryForeground)
                        HStack {
                            NumericStepper("Day",value: $landingDay, minValue: 0)
                            NumericStepper("Night",value: $landingNight, minValue: 0)
                        }
                    }
                    
                    VStack {
                        Text("IFR Approaches")
                        .foregroundStyle(Color.theme.secondaryForeground)
                        HStack {
                            NumericStepper("", value: $approachIfr, minValue: 0)
                            Text("Type")
                            TextField("Approach type", text: $approachType)
                        }
                    }
                }
                .listSectionSpacing(.compact)
            }
            .listStyle(.plain)
            
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {dismiss()}
                }
                ToolbarItem(
                    placement: .confirmationAction
                ) {
                    Button(
                        "Save"
                    ) {
                        //                        saveCrew()
                    }
                    .disabled(
                        //                        isNameInvalid
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
        guard let receivedFlight = flightToEdit else {
            return
        }
        
        self.dateStart = receivedFlight.dateStart
        self.dateEnd = receivedFlight.dateEnd ?? .now
        
        self.aircraft = receivedFlight.aircraft
        self.airportDep = receivedFlight.airportDep
        self.airportArr = receivedFlight.airportArr
        
        self.takeoffDay = Int(receivedFlight.takeoffDay)
        self.takeoffNight = Int(receivedFlight.takeoffNight)
        self.landingDay = Int(receivedFlight.landingDay)
        self.landingNight = Int(receivedFlight.landingNight)
        
        self.crewList = receivedFlight.getCrewDictionary()
        
        //    @State private var timeBlock: Int16 = 0
        //    @State private var isLocked: Bool = false
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
