//
//  FlightImporter.swift
//  SimpleLogMobile
//
//  Created by Ricardo Riet Correa on 14/02/2025.
//

import Foundation

func FlightImporter() throws {
    
    let aircraftTypeVM = AircraftTypeViewModel()
    let aircraftVM = AircraftViewModel()
    let airportVM = AirportViewModel()
    let crewVM = CrewViewModel()
    let flightVM = FlightViewModel()
    let simulatorVM = SimulatorViewModel()
    
    if let fileURL = Bundle.main.url(forResource: "flights", withExtension: "csv") {
        
        // Parse the CSV file
        let rows = try parseCSV(from: fileURL)
        
        // Skip the header row and process each row
        for row in rows.dropFirst() { // Skip the first row (headers)
            if row.count != 62 { continue } // Ensure row has all columns
            
            try addAirport(row)
            guard let airportDep = try? airportVM.getAirport(row[5]) else { return }
            
            try addAirport(row, arrival: true)
            guard let airportArr = try? airportVM.getAirport(row[12]) else { return }
            
            try addAircraftType(row)
            guard let aircraftType = try? aircraftTypeVM.getAircraftType(row[22]) else { return }
                
            try addAircraft(row, aircraftType: aircraftType)
            guard let aircraft = try? aircraftVM.getAircraft(row[19]) else { return }
            
            try addCrew(row)
            let crewPic = try? crewVM.getCrew(row[30])
            
            try addCrew(row, sic: true)
            let crewSic = try? crewVM.getCrew(row[34])
            
            try addFlight(row, airportDep: airportDep, airportArr: airportArr, aircaft: aircraft, crewPic: crewPic, crewSic: crewSic)
            
        }
    }
    
    func addAirport(_ row: [String], arrival: Bool = false) throws {
        
        var index = 5
        if arrival {
            index = 12
        }
        
        // Extract values
        let icao = row[index]
        index += 1
        
        let airportExist = try airportVM.checkExist(icao)
        if airportExist { return }
        
        let iata = row[index]
        index += 1
        let name = row[index]
        index += 1
        let city = row[index]
        index += 1
        let country = row[index]
        index += 1
        let latitude = Double(row[index]) ?? 0.0
        index += 1
        let longitude = Double(row[index]) ?? 0.0
        
        try _ = airportVM.addAirport(
            icao: icao,
            iata: iata,
            name: name,
            city: city,
            country: country,
            latitude: latitude,
            longitude: longitude
        )
    }
    
    func addAircraft(_ row: [String], aircraftType: AircraftType) throws {
        let registration = row[19]
        
        let aircraftExist = try aircraftVM.checkExist(registration)
        if aircraftExist { return }
        
        let aircraftMtow = row[20]
        let isSimulator = row[21] == "true"
        
        _ = try aircraftVM.addAircraft(
            registration: registration,
            aircraftMtow: aircraftMtow,
            aircraftType: aircraftType,
            isSimulator: isSimulator)
    }

    func addAircraftType(_ row: [String]) throws {
        let designator = row[22]
        
        let exist = try aircraftTypeVM.checkExist(designator)
        if exist { return }
        
        let family = row[23]
        let engineTypeString = row[24]
        let mtow = row[25]
        let multiEngineString = row[26] == "true"
        let multiPilotString = row[27] == "true"
        let efisString = row[28] == "true"
        let isSeaplane = row[29] == "true"
        
        var engineType: EngineTypes!
        switch engineTypeString {
        case "Turbofan":
            engineType = .Jet
        case "TurboProp":
            engineType = .Turboprop
        case "Glider":
            engineType = .Glider
        default:
            // Default "Piston"
            engineType = .Piston
        }
        
        var category: AircraftCategory!
        if isSeaplane {
            category = .Seaplane
        } else {
            category = .Landplane
        }
        
        _ = try aircraftTypeVM.addType(
            designator: designator,
            family: family,
            aircraftCategory: category,
            engineType: engineType,
            mtow: mtow,
            multiEngine: multiEngineString,
            multiPilot: multiPilotString,
            efis: efisString
        )
        
    }
    
    func addCrew(_ row: [String], sic: Bool = false) throws {
        
        var index = 30
        if sic {
            index = 34
        }
        
        let name = row[index]
        index += 1
        
        let exist = try crewVM.checkExist(name)
        if exist || name.isEmpty { return }
        
        let email = row[index]
        index += 1
        let phone = row[index]
        index += 1
        let notes = row[index]
        
        _ = try crewVM.addCrew(
            name: name,
            email: email,
            phone: phone,
            notes: notes)
    }
    
    func addFlight(_ row: [String], airportDep: Airport, airportArr: Airport, aircaft: Aircraft, crewPic: Crew?, crewSic: Crew?) throws {
        
        let depDate = Date(timeIntervalSince1970: TimeInterval(row[3]) ?? 0)
        let arrDate = Date(timeIntervalSince1970: TimeInterval(row[4]) ?? 0)
        
        let remarks = row[39]
        let notes = row[40]
        
        var crewList: [Crew: CrewPosition] = [:]
        if let pic = crewPic {
            crewList[pic] = .PIC
        }
        
        if let sic = crewSic {
            crewList[sic] = .SIC
        }
        
        // Get Simulator time before flight data
        let timeSession = Int(row[56]) ?? 0
        if timeSession > 0 {
            _ = try! simulatorVM.addSimulatorTraining(
                startDate: depDate,
                endDate: arrDate,
                aircraft: aircaft,
                remarks: remarks,
                notes: notes,
                timeSession: timeSession,
                crew: crewList,
                endorsementSignature: nil)
        } else {
            let takeOffday = row[41]
            let takeOffNight = row[42]
            let landingDay = row[43]
            let landingNight = row[44]
            let ifrApproaches = row[45]
            let approachType = row[46]
            let timeIfr = row[47]
            let timeSimulatedInstrument = row[48]
            let timeNight = row[49]
            let timeCrossCountry = row[50]
            let timePic = row[51]
            let timePicus = row[52]
            let timeSic = row[53]
            let timeDual = row[54]
            let timeInstructor = row[55]
            let timeCustom1 = row[57]
            let timeCustom2 = row[58]
            let timeCustom3 = row[59]
            let timeCustom4 = row[60]
            let timeTotalBlock = row[61]
            
            _ = try flightVM.addFlight(
                depDate: depDate,
                arrDate: arrDate,
                airportDep: airportDep,
                airportArr: airportArr,
                aircaft: aircaft,
                remarks: remarks,
                notes: notes,
                takeOffday: Int(takeOffday) ?? 0,
                takeOffNight: Int(takeOffNight) ?? 0,
                landingDay: Int(landingDay) ?? 0,
                landingNight: Int(landingNight) ?? 0,
                ifrApproaches: Int(ifrApproaches) ?? 0,
                approachType: approachType,
                timeIfr: Int(timeIfr) ?? 0,
                timeSimulatedInstrument: Int(timeSimulatedInstrument) ?? 0,
                timeNight: Int(timeNight) ?? 0,
                timeCrossCountry: Int(timeCrossCountry) ?? 0,
                timePic: Int(timePic) ?? 0,
                timePicus: Int(timePicus) ?? 0,
                timeSic: Int(timeSic) ?? 0,
                timeDual: Int(timeDual) ?? 0,
                timeInstructor: Int(timeInstructor) ?? 0,
                timeCustom1: Int(timeCustom1) ?? 0,
                timeCustom2: Int(timeCustom2) ?? 0,
                timeCustom3: Int(timeCustom3) ?? 0,
                timeCustom4: Int(timeCustom4) ?? 0,
                timeTotalBlock: Int(timeTotalBlock) ?? 0,
                timeTotalFlight: 0,
                crew: crewList)
        }
        
    }
}
