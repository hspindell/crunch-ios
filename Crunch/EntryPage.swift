//
//  EntryPage.swift
//  Crunch
//
//  Created by Henry Spindell on 5/15/24.
//

import SwiftUI

struct EntryPage: View {
    @EnvironmentObject var appObject: AppObject
    @Environment(\.dismiss) var dismiss
    var pool: Pool
    var entry: Entry
    var event: Event
    
    @State var entryTitle = ""
    
    var isMyEntry: Bool {
        entry.profile_id == appObject.userProfile.id
    }
    
    var viewable: Bool {
        isMyEntry || event.started
    }

    var editable: Bool {
        isMyEntry && !event.started
    }
    
    func detailText() -> String {
        if isMyEntry && !event.started {
            return "\nEvent has not started; you may edit your selections until \(event.starts_at.formatted(.dateTime.weekday(.wide).month().day().hour().minute().timeZone()))."
        } else if !isMyEntry && !event.started {
            return "\nYou may view other users' entries once the event has started (\(event.starts_at.formatted(.dateTime.weekday(.wide).month().day().hour().minute().timeZone())))."
        } else if isMyEntry && event.started {
            return "\nEvent has started; your entry can only be modified by the pool admin."
        } else { return "" }
    }
    
    init(pool: Pool, entry: Entry, event: Event) {
        self.pool = pool
        self.entry = entry
        self.event = event
        self._entryTitle = State(initialValue: entry.title)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.title.presence ?? "\(entry.profile?.username ?? "User")'s Entry")
                            .font(.system(size: 20, weight: .semibold))
                            .padding(top: 8, leading: 15, bottom: 8, trailing: 8)
                            .leadingHighlight(Color.black)
                            .foregroundStyle(Color.white)
                        
                        Text("\(pool.title) (\(pool.pool_type))")
                        .font(.system(size: 12))
                        .padding(top: 8, leading: 15, bottom: 8, trailing: 8)
                        .highlighted(.black)
                        .foregroundStyle(Color.white)
                    }
                    .padding(leading: -15)
                    Spacer()
                    CloseButton()
                }.padding(bottom: 10)
                
//                if isMyEntry && !event.started {
//                    TextField("", text: $entryTitle)
//                        .textFieldStyle(CrunchFieldStyle())
//                        .labeled("Entry name")
//                } else {

//                }
                // TODO enable editing entry title
                
                (
                Text("Entry is \(entry.complete ? "complete" : "incomplete").")
                    .fontWeight(.semibold)
                +
                Text(detailText())
                )
                .font(.system(size: 12))
                .messageBox()

                Spacer()
                switch pool.poolType {
                case .golfPickSix:
                    GolfPickSix(event: event, entry: entry)
                case .none:
                    Text("This pool type is not yet supported. Try updating from the App Store.")
                }
                
                Spacer()
            }
            .padding(15)

        }
        .padding(top: 50) // TODO better approach for safe areas
        .ignoresSafeArea(.all)
        .background(StripeBG())
    }
}

// TODO sample data
#Preview {
    EntryPage(pool: Pool.sample, entry: Entry.sample, event: Event.sample)
        .environmentObject(AppObject.sample)
        .environmentObject(PoolObject())
}
