//
//  TimelineView.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/23/25.
//

import SwiftUI
import CoreData

struct TimelineView: View {
    
    @StateObject private var timelineVM = TimelineViewModel()
    
    @State private var showAddDialog = false
    @State private var showAddEditFlight = false
    
    @State private var selectedFlight: Flight?
    
    
    var body: some View {
        ZStack{
            VStack {
                Text("SimpleLog")
                    .font(.title)
                    .padding(.vertical, 1)
                    
                if !timelineVM.timelineList.isEmpty {
                    List {
                        ForEach(timelineVM.timelineList, id: \.self) { event in
                            Section(header: Text(event.getDate.formatted())) {
                                
                                if event.hasFlight {
                                    FlightRowView(
                                        flight: event.flight,
                                        onDelete: {
                                            
                                        },
                                        onEdit: {

                                        },
                                        onTapGesture: {

                                        },
                                        onToggleLock: {
//                                            try! crewVM.toggleLocked(crew)
                                        },
                                        onImageTapGesture: {
//                                            selectedCrew = crew
//                                            showLargeImage = true
                                        })
                                }
                                
                            }
                            .onAppear {
                                if event == timelineVM.timelineList.last {
                                    try! timelineVM.fetchTimelineList(offset: timelineVM.timelineList.count)
                                }
                            }
                        }
                        // Spacer to allow last entry to scroll pass the + button
                        Section {
                            Spacer()
                                .frame(height: 100)
                                .listRowBackground(Color.clear)
                        }
                        
                    }
                    
                } else {
                    Text("Nothing logged yet...")
                        .font(.subheadline)
                        .foregroundColor(Color.theme.foreground)
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity,
                            alignment: .center
                        )
                        .background(Color.theme.secondaryBackground)
                }
                
            }
            VStack {
                // VStack with spacer to position the confirmation dialog in the bottom of the screen for iPad
                Spacer()
                Text("")
                    .confirmationDialog("Change background", isPresented: $showAddDialog) {
                        Button("Next Flight") { addFlight() }
                        Button("Return Flight") {
//                            try! timelineVM.addRandomData()
//                            try! timelineVM.fetchTimelineList()
                        }
                        Button("Duty") {
//                            try! AirportImporter()
                            try! FlightImporter()
                        }
                        Button("Simulator") { }
                        Button("Positioning") { }
                        Button("Cancel", role: .cancel) { }
                    }
            }
        }
        .floatingButton(
            buttonContent: AnyView(
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .font(.title)
            ), action: {showAddDialog.toggle()})
        
        .sheet(isPresented: $showAddEditFlight) {
            AddEditFlight($selectedFlight, timelineVM: timelineVM)
                .interactiveDismissDisabled()
        }
        .onAppear {
            try! timelineVM.fetchTimelineList(refresh: true)
        }
    }
    
    private func addFlight() {
        selectedFlight = nil
        showAddEditFlight.toggle()
    }
}
