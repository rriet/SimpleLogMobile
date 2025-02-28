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
    @State private var showSearch = false
    @State private var dateFrom: Date = Date()
    @State private var dateTo: Date = Date()
    @State private var searchText: String = ""
    @State private var selectedFlight: Flight?
    
    
    var body: some View {
        ZStack{
            VStack {
                HStack{
                    Button {
                        showSearch.toggle()
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.system(size: 20, weight: .bold))
                            .frame(width: 34, height: 34)
                    }
                    Spacer()
                    Text("SimpleLog")
                        .font(.headline)
                    Spacer()
                    Button {
                        showAddDialog.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .bold))
                            .frame(width: 34, height: 34)
                    }
                    .confirmationDialog("Change background", isPresented: $showAddDialog) {
                        Button("New Flight") { addFlight() }
                        Button("Next Flight") {
                            // TODO:
                        }
                        Button("Return Flight") {
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
                .padding(.horizontal)
                
                if showSearch {
                    VStack{
                        ViewThatFits {
                            HStack{
                                InputDate(
                                    title: "From",
                                    dateStart: $dateFrom
                                )
                                Spacer().frame(minWidth: 0, maxWidth: 25)
                                InputDate(
                                    title: "To",
                                    dateStart: $dateTo
                                )
                            }
                            .padding(.horizontal)
                            
                            HStack{
                                VStack{
                                    Text("From")
                                    InputDate(
                                        title: "",
                                        dateStart: $dateFrom
                                    )
                                }
                                
                                VStack{
                                    Text("To")
                                    InputDate(
                                        title: "",
                                        dateStart: $dateTo
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                        HStack{
                            Text("Search")
                            TextField("Airport, Aircraft, Type, Crew or Remaks", text: $searchText)
                                .autocorrectionDisabled(true)
                                .minimumScaleFactor(0.8)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onChange(of: searchText) { oldValue , newValue in
                                    //                                filterCrewList()
                                }
                                
                        }
                        .padding(.horizontal)
                    }
                    
                    
                }
                    
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
                                            selectedFlight = event.flight
                                            showAddEditFlight = true
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
                                
                                if event.hasSimulatorTraining {
                                    Text("\(event.simulatorTraining.dateStart)")
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
        }
        .sheet(isPresented: $showAddEditFlight) {
            AddEditFlight($selectedFlight, timelineVM: timelineVM)
                .interactiveDismissDisabled()
        }
        .onAppear {
            try! timelineVM.fetchTimelineList()
        }
    }
    
    private func addFlight() {
        selectedFlight = nil
        showAddEditFlight.toggle()
    }
}
