//
//  FlightImporter.swift
//  SimpleLogMobile
//
//  Created by Ricardo Riet Correa on 14/02/2025.
//

// "Date (DD/MM/YYYY)","Departure Time (HH:MM)","Arrival Time (HH:MM)","Departure Epoch","Arrival Epoch","Departure Icao","Departure Iata","Departure Airport Name","Departure City","Departure Country","Departure Latitude","Departure Longitude","Arrival Icao","Arrival Iata","Arrival Airport Name","Arrival City","Arrival Country","Arrival Latitude","Arrival Longitude","Aircraft Registration","Aircraft MTOW","Aircraft Simulator","Model Make & Model","Model Group","Model Engine Type","Model MTOW","Model Multi Engine","Model Multi Pilot","Model EFIS","Model Seaplane","PIC Name","PIC Email","PIC Phone","PIC Comments","SIC Name","SIC Email","SIC Phone","SIC Comments","Pilot Function","Remarks","Private notes","Takeoff day","Takeoff night","Landing day","Landing night","IFR Approaches","Approach Type","IFR Minutes","Simulated Instrument Minutes","Night Minutes","Corss country Minutes","PIC Minutes","PICUS Minutes","SIC Minutes","Dual Minutes","Instructor Minutes","Simulator Minutes","Custom Time 1 Minutes","Custom Time 2 Minutes","Custom Time 3 Minutes","Custom Time 4 Minutes","Total Minutes"

import Foundation

func FlightImporter() throws {
    
    let aircraftTypeVM = AircraftTypeViewModel()
    let aircraftVM = AircraftViewModel()
    let airportVM = AirportViewModel()
    let crewVM = CrewViewModel()
    
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
            
            if aircraft.isSimulator {
                // Add simulator training
            } else {
                try addFlight(
                    row,
                    airportDep: airportDep,
                    airportArr: airportArr,
                    aircaft: aircraft,
                    crewPic: crewPic,
                    crewSic: crewSic)
            }
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
        
        var crew = CrewModel()
        
        var index = 30
        if sic {
            index = 34
        }
        
        crew.name = row[index]
        index += 1
        
        let exist = try crewVM.checkExist(crew.name)
        if exist || crew.name.isEmpty { return }
        
        crew.email = row[index]
        index += 1
        crew.phone = row[index]
        index += 1
        crew.notes = row[index]
        
        _ = try crewVM.addCrew(crew)
    }
    
    func addFlight(_ row: [String], airportDep: Airport, airportArr: Airport, aircaft: Aircraft, crewPic: Crew?, crewSic: Crew?) throws {
        
        let depDate = Date(timeIntervalSince1970: TimeInterval(row[3]) ?? 0)
        let arrDate = Date(timeIntervalSince1970: TimeInterval(row[4]) ?? 0)
        
        let remarks = row[39]
        let notes = row[40]
        let takeOffday = row[41]
        let takeOffNight = row[42]
        let landingDay = row[43]
        let landingNight = row[44]
        let ifrApproaches = row[45]
        let approachType = row[46]
        let ifrTime = row[47]
        let simInstTime = row[48]
        let nightTime = row[49]
        let crossCountryTime = row[50]
        let picTime = row[51]
        let picusTime = row[52]
        let sicTime = row[53]
        let dualTime = row[54]
        let instructorTime = row[55]
        let simulatorTime = row[56]
        let customTime1 = row[57]
        let customTime2 = row[58]
        let customTime3 = row[59]
        let customTime4 = row[60]
        let totalTime = row[61]
        
        print(totalTime)
    }
    
}
