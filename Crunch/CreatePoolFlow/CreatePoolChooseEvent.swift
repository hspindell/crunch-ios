//
//  CreatePoolChooseEvent.swift
//  Crunch
//
//  Created by Henry Spindell on 6/12/24.
//

import SwiftUI

struct CreatePoolChooseEvent: View {
    @EnvironmentObject var appObject: AppObject
    @EnvironmentObject var manager: CreateCircleManager
    @State var selectedEvent: Event?
    @State var events = [Event]()
    
    private func fetchUpcomingEvents() async {
        do {
            let result: [Event] = try await supabase
                .from("events")
                .select()
                .greaterThanOrEquals("starts_at", value: Date().ISO8601Format())
                .order("starts_at", ascending: true)
                .execute()
                .value
            await MainActor.run {
                events = result
            }
        } catch {
            print("fetchUpcomingEvents: \(error.localizedDescription)")
        }
    }
    
    var body: some View {
        CreatePoolStepBody(title: "Select an event") {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 15) {
                    ForEach(events) { event in
                        EventCard(event: event, selected: selectedEvent == event)
                        .padding(h: 5)
                        .onTapGesture {
                            selectedEvent = event
                        }
                    }
                }.padding(v: 15)
            }
            
            Button("Continue") {
                manager.event = selectedEvent
                manager.slideTo(step: .details)
            }
            .buttonStyle(CrunchButtonStyle(flow: true))
            .disabled(selectedEvent.isNil)
        }
        .task {
            await fetchUpcomingEvents()
        }
    }
}

#Preview {
    CreatePoolChooseEvent()
        .environmentObject(AppObject.sample)
        .environmentObject(CreateCircleManager())
}
