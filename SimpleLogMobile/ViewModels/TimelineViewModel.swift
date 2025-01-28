//
//  TimelineViewModel.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/23/25.
//

import Foundation
import CoreData

class TimelineViewModel: ObservableObject {
    private let viewContext = PersistenceController.shared.viewContext
    @Published var timelineList: [Timeline] = []
    
    init() {
        try? fetchTimelineList()
    }
    
    func fetchTimelineList() throws {
        let request = Timeline.fetchRequest()
        let sort = NSSortDescriptor(key: "dateValue", ascending: true)
        request.sortDescriptors = [sort]
        
        do {
            timelineList = try viewContext.fetch(request)
        }catch {
            throw ErrorDetails(
                title: "Error!",
                message: "Unknown error fetching crew.")
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
