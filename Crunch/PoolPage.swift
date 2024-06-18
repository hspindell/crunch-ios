//
//  PoolPage.swift
//  Crunch
//
//  Created by Henry Spindell on 5/8/24.
//

import SwiftUI
import Supabase



//struct EntryOverview: Codable {
//    var id: String { profile_id.uuidString + pool_id.uuidString }
//    var profile_id: UUID
//    var pool_id: UUID
//    var complete: Bool
//    var created_at: Date?
//    var profile: Profile
//}

class PoolObject: ObservableObject {
    var pool: Pool
    @Published var event: Event?
    @Published var entries = [Entry]()
    
    init(pool: Pool) {
        self.pool = pool
    }
}

class GolfPoolObject: PoolObject {
    @Published var topGolfers = [Golfer]()
    @Published var golfersById = [String : Golfer]()
    
    func fetchGolfers() async {
        do {
            let result: [Golfer] = try await supabase
                .rpc("top_golfers_for_event", params: ["start_date": (event?.starts_at ?? Date()).ISO8601Format()])
                .select()
              .execute()
              .value
            
            var idMap = [String: Golfer]()
            result.forEach { g in
                idMap[g.id.description] = g
            }
            await MainActor.run { [idMap] in
                topGolfers = result
                golfersById = idMap
            }
        } catch {
            print("fetchGolfers: \(error.localizedDescription)")
        }
    }
    
    override init(pool: Pool) {
        super.init(pool: pool)
        self.event = pool.event
        Task {
            await fetchGolfers()
        }
    }
}

struct PoolPage: View {
    @EnvironmentObject var appObject: AppObject
    @Environment(\.dismiss) var dismiss
    @StateObject var poolObject: PoolObject
    var pool: Pool
    @State var showEntry: Entry?
    
    func joinPool() async {
        do {
            let entryReq = EntryCreation(pool_id: pool.id, title: "\(appObject.userProfile.username)'s Entry")
            var newEntry: Entry = try await supabase
                .from("entries")
                .insert(entryReq)
                .select()
                .single()
                .execute()
                .value
            var copy = poolObject.entries
            newEntry.profile = appObject.userProfile
            copy.append(newEntry)
            poolObject.entries = copy
            await MainActor.run {
                showEntry = newEntry
            }
        } catch {
            print("joinPool: \(error.localizedDescription)")
        }
    }
    
    func fetchEvent() async {
        do {
            poolObject.event = try await supabase
                .from("events")
                .select()
                .eq("id", value: pool.event_id)
                .single()
                .execute()
              .value
        } catch {
            print("fetchEvent: \(error.localizedDescription)")
        }
    }
    
    func fetchEntries() async {
        do {
            poolObject.entries = try await supabase
                .from("entries")
                .select(
                    """
                    *, profile:profile_id(*)
                    """
                )
                .eq("pool_id", value: pool.id)
                .order("created_at", ascending: true)
                .execute()
              .value
        } catch {
            print("fetchEntries: \(error.localizedDescription)")
        }
    }
    
    init(pool: Pool) {
        self.pool = pool
        self._poolObject = StateObject(wrappedValue: GolfPoolObject(pool: pool))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(pool.title)
                            .font(.system(size: 20, weight: .semibold))
                            .padding(leading: 15)
                            .leadingHighlight()
                        Text(pool.pool_type)
                            .font(.system(size: 14, weight: .semibold))
                            .padding(leading: 15)
                            .leadingHighlight()
                    }
                    Spacer()
                    CloseButton()
                        .padding(trailing: 15)
                }
                Spacer()
                HStack(alignment: .bottom) {
                    EventLogo(url: poolObject.event?.logoURL)
                    .padding(leading: 15)
                    
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(pool.event?.title ?? "Unknown event")
                            .font(.system(size: 14, weight: .semibold))
                            .padding(trailing: 15)
                            .trailingHighlight(.black)
                        Text("\(poolObject.event?.starts_at.formatted(date: .abbreviated, time: .omitted) ?? "Start date TBD")")
                            .font(.system(size: 14, weight: .semibold))
                            .padding(trailing: 15)
                            .trailingHighlight(.black)
                    }
                    .foregroundStyle(Color.white)
                }
            }
            .padding(v: 15)
            .frame(height: 175)
            .background(
                Color.crunchCyan
                    .overlay {
                        AsyncImage(url: pool.event?.coverImageURL) { result in
                            result.image?
                                .resizable()
                                .scaledToFill()
                        }
                    }
                    .clipped()
                    .edgesIgnoringSafeArea(.all)
            )

            VStack(alignment: .leading, spacing: 10) {
                if let details = pool.details, details.isPresent {
                    Text(details)
                        .font(.system(size: 12))
                        .messageBox()
                }
                
                if let event = poolObject.event, event.started == true {
                    Text("This event has started and entries have been locked.")
                        .font(.system(size: 12))
                        .messageBox()
                    
                    Text("Leaderboard")
                        .font(.system(size: 18, weight: .semibold))
                        .padding(top: 15)
                    
                    if poolObject.entries.filter(\.complete).isEmpty {
                        Divider()
                        Text("No entries were submitted.")
                            .font(.system(size: 12))
                    } else if pool.poolType == .golfPickSix {
                        GolfPoolLeaderboard(event: event, selectedEntry: $showEntry)
                    }
                } else {
                    Text("Entries will be locked on \(poolObject.event?.starts_at.formatted(.dateTime.weekday(.wide).month().day().hour().minute().timeZone()) ?? "TBD").")
                        .font(.system(size: 12))
                        .messageBox()
                    
                    HStack {
                        Text("Entries")
                            .font(.system(size: 18, weight: .semibold))
                            
                        Spacer()
                        if !poolObject.entries.contains(where: { $0.profile_id == appObject.userProfile.id }) {
                            JoinButton()
                                .onTapGesture {
                                    Task {
                                        await joinPool()
                                    }
                                }
                        } else if pool.admin_id == appObject.userProfile.id || pool.is_public {
                            ShareLink(item: DeepLink.build(action: .joinPool, params: [URLQueryItem(name: "id", value: pool.id.uuidString)])) {
                                InviteButton()
                            }
                        }
                    }.padding(top: 20)
                    Divider()
                    
                    if poolObject.entries.isEmpty {
                        Text("No entries have been submitted yet.")
                    } else {
                        ScrollView {
                            ForEach(poolObject.entries) { e in
                                MemberEntry(entry: e)
                                    .onTapGesture {
                                        showEntry = e
                                    }
                                    .padding(h: 10)
                            }
                        }
                    }
                }
            }.padding(h: 15)

            Spacer()
        }
        .background(StripeBG())
        .fullScreenCover(item: $showEntry, onDismiss: {
            Task { await fetchEntries() }
        }) { entry in
            if let event = poolObject.event {
                EntryPage(pool: pool, entry: entry, event: event)
            }
        }
        .task {
            await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask { await fetchEvent() }
                group.addTask { await fetchEntries() }
            }
        }
        .environmentObject(poolObject)
    }
}

struct JoinButton: View {
    var text = "Join"
    var body: some View {
        Text("\(Image(systemName: "plus")) \(text)")
            .foregroundStyle(Color.crunchCyan.shade(15))
            .font(.system(size: 14, weight: .bold))
    }
}

struct InviteButton: View {
    var body: some View {
        Text("\(Image(systemName: "paperplane")) Invite")
            .foregroundStyle(Color.crunchCyan.shade(15))
            .font(.system(size: 14, weight: .bold))
    }
}

struct CloseButton: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Text("X")
            .font(.system(size: 16, weight: .bold))
            .padding(8)
            .background(Color.white)
            .clipShape(Circle())
            .onTapGesture {
                dismiss()
            }
    }
}

#Preview {
    PoolPage(pool: Pool.sample)
}
