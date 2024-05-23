//
//  CreatePoolPage.swift
//  Crunch
//
//  Created by Henry Spindell on 5/7/24.
//

import SwiftUI

struct Pool: Codable, Identifiable {
    var id: UUID
    var created_at: Date
    var circle_id: UUID?
    var admin_id: UUID
    var event_id: UUID
    var title: String
    var details: String?
    var pool_type: String
    var is_public: Bool
    
    var poolType: PoolType? {
        PoolType(rawValue: pool_type)
    }
    enum PoolType: String, Codable {
        case golfPickSix = "golf-pick-six"
    }
}

struct PoolCreate: Codable {
    var circle_id: UUID?
    var event_id: UUID
    var title: String
    var details: String?
    var pool_type: Pool.PoolType
    var is_public: Bool
}

struct CreatePoolPage: View {
    @EnvironmentObject var appObject: AppObject
    @Environment(\.dismiss) var dismiss
    var allowCircleChange = false
    
    @State var circle: Circle?
    @State var events = [Event]()
    @State var poolName = ""
    @State var details = ""
    @State var isPublic = true
    @State var event: Event?
    @State var poolHostedByCircle = true
    
    var poolCircle: Circle? {
        poolHostedByCircle ? circle : nil
    }
    
    var circlesAsAdmin: [Circle] {
        appObject.circles.filter({ $0.owner_id == appObject.userProfile.id })
    }
    
    func fetchUpcomingEvents() async {
        do {
            let result: [Event] = try await supabase
                .from("events")
                .select()
                .execute()
              .value
            await MainActor.run {
                events = result
            }
        } catch {
            print("fetchUpcomingEvents: \(error.localizedDescription)")
        }
    }
    
    func defaultPoolTitle(circle: Circle?, event: Event?) -> String {
        let owner = circle?.title ?? appObject.userProfile.username
        guard let event else {
            return "\(owner)'s Pool"
        }
        return "\(owner)'s \(event.title) Pool"
    }
    
    init(allowCircleChange: Bool = false, circle: Circle? = nil) {
        self.allowCircleChange = allowCircleChange
        self._circle = State(initialValue: circle)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Button("Back") {
                dismiss()
            }
            
            Text("Create Pool")
                .font(.title)
            
            if allowCircleChange {
                Text("Choose a circle")
                    .font(.title3)
                Toggle("Pool is hosted by circle", isOn: circlesAsAdmin.isEmpty ? .constant(false) : $poolHostedByCircle)
                    .disabled(circlesAsAdmin.isEmpty)
                
                if poolHostedByCircle {
                    if circlesAsAdmin.isEmpty {
                        Text("You must be the admin of a circle to host a pool for it")
                    } else {
                        List(circlesAsAdmin) { c in
                            Text(c.title)
                                .fontWeight(c.id == circle?.id ? .bold : .regular)
                                .onTapGesture {
                                    circle = c
                                }
                        }
                    }
                }
            }
            
            Spacer()
            
            Text("Choose an event")
                .font(.title3)
            List(events) { e in
                Text(e.title)
                    .fontWeight(e.id == event?.id ? .bold : .regular)
                    .onTapGesture {
                        event = e
                    }
            }
            Spacer()
            
            // give pool a name (default: Circle name + event name)
            Text("Pool name")
                .font(.title3)
            TextField("Pool name", text: $poolName)
                .textFieldStyle(.roundedBorder)
            
            // TODO circle selection if not already coming from a circle page
            
            // description/payout structure (optional)
            Text("Pool details (buy-in, payout structure, etc)")
                .font(.title3)
            TextField("Details", text: $details)
                .textFieldStyle(.roundedBorder)
            
            // public/private (private = invite only, members of the circle automatically invited)
            Toggle(isOn: $isPublic) {
                Text("Public")
            }
            if isPublic {
                Text("Pool will be listed publicly and anyone will be allowed to join")
                    .font(.caption)
            } else {
                Text("Pool will only be findable by those with the link")
                    .font(.caption)
            }
            
            // OPTIONAL select circle this pool is hosted by (amongst ones user is admin for)
            // depending on if this page was opened in context of a circle already
            
            // TODO option to invite more people from other circles you are part of, + generic link
            //            Text("All members of (circle) will be invited automatically. Optionally invite other people you know from the list below or use the following link.")
            //                .font(.footnote)
            
            
            Spacer()
            
            HStack {
                Spacer()
                Button("Create") {
                    guard let event else { return }
                    Task {
                        do {
                            let newPool = PoolCreate(circle_id: circle?.id, event_id: event.id, title: poolName, details: details, pool_type: .golfPickSix, is_public: isPublic)
                            try await supabase
                                .from("pools")
                                .insert(newPool)
                                .execute()
                            dismiss()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
                .disabled(poolName.isEmpty || event.isNil)
                Spacer()
            }
        }
        .padding(30)
        .onChange(of: circle) { oldValue, newValue in
            poolName = defaultPoolTitle(circle: newValue, event: event)
        }
        .onChange(of: event) { oldValue, newValue in
            poolName = defaultPoolTitle(circle: poolCircle, event: newValue)
        }
        .onChange(of: poolHostedByCircle) { oldValue, newValue in
            poolName = defaultPoolTitle(circle: poolCircle, event: event)
        }
        .onAppear {
            self.circle = self.circle ?? circlesAsAdmin.first
        }
        .task {
            await fetchUpcomingEvents()
        }
    }
}

#Preview {
    CreatePoolPage()
}
