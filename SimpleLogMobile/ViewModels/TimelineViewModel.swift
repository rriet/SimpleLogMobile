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
    
    private var batchSize = 20
    
    func fetchTimelineList(offset: Int = 0, refresh: Bool = false) throws {
        let request = Timeline.fetchRequest()
        let sort = NSSortDescriptor(key: "dateValue", ascending: false)
        request.sortDescriptors = [sort]
        request.fetchLimit = batchSize
        request.fetchOffset = offset
        
        do {
            let listResult = try viewContext.fetch(request)
            
            DispatchQueue.main.async {
                if refresh {
                    self.timelineList = listResult
                } else {
                    self.timelineList.append(contentsOf: listResult)
                }
            }
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
