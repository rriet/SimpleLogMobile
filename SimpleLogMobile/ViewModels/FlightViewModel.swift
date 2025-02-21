//
//  FlightViewModel.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/23/25.
//

import Foundation
import CoreData

class FlightViewModel: ObservableObject {
    
    private let defaults = UserDefaults.standard
    private let viewContext = PersistenceController.shared.viewContext
    
    func addFlight(
        depDate: Date,
        arrDate: Date,
        airportDep: Airport,
        airportArr: Airport,
        aircaft: Aircraft,
        remarks: String,
        notes: String,
        takeOffday: Int,
        takeOffNight: Int,
        landingDay: Int,
        landingNight: Int,
        ifrApproaches: Int,
        approachType: String,
        timeIfr: Int,
        timeSimulatedInstrument: Int,
        timeNight: Int,
        timeCrossCountry: Int,
        timePic: Int,
        timePicus: Int,
        timeSic: Int,
        timeDual: Int,
        timeInstructor: Int,
        timeCustom1: Int,
        timeCustom2: Int,
        timeCustom3: Int,
        timeCustom4: Int,
        timeTotalBlock: Int,
        timeTotalFlight: Int,
        crew: [Crew: CrewPosition]
    ) throws -> Flight {
        
        let newFlight = Flight(context: viewContext)
        newFlight.startTimeline = Timeline(context: viewContext)
        
        try editFlight(
            newFlight,
            depDate: depDate,
            arrDate: arrDate,
            airportDep: airportDep,
            airportArr: airportArr,
            aircaft: aircaft,
            remarks: remarks,
            notes: notes,
            takeOffday: takeOffday,
            takeOffNight: takeOffNight,
            landingDay: landingDay,
            landingNight: landingNight,
            ifrApproaches: ifrApproaches,
            approachType: approachType,
            timeIfr: timeIfr,
            timeSimulatedInstrument: timeSimulatedInstrument,
            timeNight: timeNight,
            timeCrossCountry: timeCrossCountry,
            timePic: timePic,
            timePicus: timePicus,
            timeSic: timeSic,
            timeDual: timeDual,
            timeInstructor: timeInstructor,
            timeCustom1: timeCustom1,
            timeCustom2: timeCustom2,
            timeCustom3: timeCustom3,
            timeCustom4: timeCustom4,
            timeTotalBlock: timeTotalBlock,
            timeTotalFlight: timeTotalFlight,
            crew: crew,
            isLocked: AppSettings.autoLockNewEntries)
        return newFlight
    }
    
    func editFlight(_ flightToEdit: Flight,
                    depDate: Date,
                    arrDate: Date,
                    airportDep: Airport,
                    airportArr: Airport,
                    aircaft: Aircraft,
                    remarks: String,
                    notes: String,
                    takeOffday: Int,
                    takeOffNight: Int,
                    landingDay: Int,
                    landingNight: Int,
                    ifrApproaches: Int,
                    approachType: String,
                    timeIfr: Int,
                    timeSimulatedInstrument: Int,
                    timeNight: Int,
                    timeCrossCountry: Int,
                    timePic: Int,
                    timePicus: Int,
                    timeSic: Int,
                    timeDual: Int,
                    timeInstructor: Int,
                    timeCustom1: Int,
                    timeCustom2: Int,
                    timeCustom3: Int,
                    timeCustom4: Int,
                    timeTotalBlock: Int,
                    timeTotalFlight: Int,
                    crew: [Crew: CrewPosition],
                    isLocked: Bool = false
    ) throws {
        
        flightToEdit.startTimeline!.dateValue = depDate
        flightToEdit.dateEnd = arrDate
        flightToEdit.airportDep = airportDep
        flightToEdit.airportArr = airportArr
        flightToEdit.aircraft = aircaft
        flightToEdit.remarks = remarks
        flightToEdit.notes = notes
        flightToEdit.takeoffDay = Int16(takeOffday)
        flightToEdit.takeoffNight = Int16(takeOffNight)
        flightToEdit.landingDay = Int16(landingDay)
        flightToEdit.landingNight = Int16(landingNight)
        flightToEdit.ifrApproaches = Int16(ifrApproaches)
        flightToEdit.approachType = approachType
        flightToEdit.timeIfr = Int16(timeIfr)
        flightToEdit.timeSimulatedInstrument = Int16(timeSimulatedInstrument)
        flightToEdit.timeNight = Int16(timeNight)
        flightToEdit.timeCrossCountry = Int16(timeCrossCountry)
        flightToEdit.timePic = Int16(timePic)
        flightToEdit.timePicUs = Int16(timePicus)
        flightToEdit.timeSic = Int16(timeSic)
        flightToEdit.timeDual = Int16(timeDual)
        flightToEdit.timeInstructor = Int16(timeInstructor)
        flightToEdit.timeCustom1 = Int16(timeCustom1)
        flightToEdit.timeCustom2 = Int16(timeCustom2)
        flightToEdit.timeCustom3 = Int16(timeCustom3)
        flightToEdit.timeCustom4 = Int16(timeCustom4)
        flightToEdit.timeTotalBlock = Int16(timeTotalBlock)
        flightToEdit.timeTotalFlight = Int16(timeTotalFlight)
        
        updateCrew(flightToEdit, crew: crew)
        
        try save()
    }
    
    private func updateCrew(_ flight: Flight, crew: [Crew: CrewPosition]) {
        let currentCrew = flight.flightCrew as? Set<FlightCrew> ?? []

        if crew.isEmpty {
            // Remove all crew assignments
            currentCrew.forEach { viewContext.delete($0) }
        } else {
            // Update existing and add new crew members
            crew.forEach { (crewMember, position) in
                if let existingAssignment = currentCrew.first(where: { $0.crew == crewMember }) {
                    existingAssignment.position = position
                } else {
                    let newAssignment = FlightCrew(context: viewContext)
                    newAssignment.flight = flight
                    newAssignment.crew = crewMember
                    newAssignment.position = position
                }
            }
        }
    }
    
    func flightDepDateFetchRequest(for departureDate: Date) -> NSFetchRequest<Flight> {
        let request = Flight.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "startTimeline.dateValue == %@", departureDate as NSDate)
        return request
    }

    func checkExist(_ departureDate: Date) throws -> Bool {
        let request = flightDepDateFetchRequest(for: departureDate)
        do {
            return try viewContext.count(for: request) > 0
        } catch {
            throw ErrorDetails(title: "Error!", message: "Unknown error reading from database.")
        }
    }

    func getFlight(_ departureDate: Date) throws -> Flight? {
        let request = flightDepDateFetchRequest(for: departureDate)
        do {
            return try viewContext.fetch(request).first
        } catch {
            throw ErrorDetails(title: "Error!", message: "Unknown error reading from database.")
        }
    }
    
    private func save() throws {
        do {
            try viewContext.save()
        } catch {
            throw ErrorDetails(
                title: "Error!",
                message: "There was an unknown error saving to database.")
        }
    }
}
