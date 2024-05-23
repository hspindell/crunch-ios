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

struct Event: Codable, Identifiable, Hashable {
    var id: UUID
    var title: String
    var logo_url: String?
    var cover_image_url: String?
    var starts_at: Date
    var external_id: String?
    
    var logoURL: URL? { logo_url?.url }
    var coverImageURL: URL? { cover_image_url?.url }
    
    var started: Bool {
        return Date() > starts_at
    }
    
    var lockDateDisplay: String? {
//        guard let starts_at else { return nil }
        return starts_at.formatted(.dateTime.weekday(.wide).month().day().hour().minute().timeZone())
    }
}

class PoolObject: ObservableObject {
    @Published var event: Event?
    @Published var entries = [Entry]()
}

class GolfPoolObject: PoolObject {
    @Published var topGolfers = [Golfer]()
    @Published var golfersById = [String : Golfer]()
    
    func fetchGolfers() async throws {
        // TODO cache?
        let result: [Golfer] = try await supabase
            .from("current_top_golfers")
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
    }
    
    override init() {
        super.init()
        Task {
            try await fetchGolfers()
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
        self._poolObject = StateObject(wrappedValue: GolfPoolObject())
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Button("Back") {
                dismiss()
            }
            ZStack {
                AsyncImage(url: poolObject.event?.coverImageURL) { result in
                    result.image?
                        .resizable()
                        .scaledToFit()
                }.frame(height: 200)
                HStack {
                    AsyncImage(url: poolObject.event?.logoURL) { result in
                        result.image?
                            .resizable()
                            .scaledToFit()
                    }.frame(height: 100)
                    VStack {
                        // TODO allow edit title if pool owner
                        Text(pool.title)
                            .font(.title)
                        Text("\(poolObject.event?.title ?? "Event ?") (\(pool.pool_type))")
                            .font(.title3)
                        Text("\(poolObject.event?.starts_at.formatted(date: .abbreviated, time: .omitted) ?? "Start date TBD")")
                            .font(.title3)
                    }
                }
            }
            if let event = poolObject.event, event.started == true {
                Text("The event has started and entries have been locked.")
                
                Spacer()
                Text("Leaderboard")
                    .font(.title2)
                
                if pool.poolType == .golfPickSix {
                    GolfPoolLeaderboard(event: event, selectedEntry: $showEntry)
                }
            } else {
                Text("Entries will be locked on \(poolObject.event?.starts_at.formatted(.dateTime.weekday(.wide).month().day().hour().minute().timeZone()) ?? "TBD").")
                Spacer()
                
                HStack {
                    Text("Entries")
                        .font(.title2)
                    Spacer()        
                    if !poolObject.entries.contains(where: { $0.profile_id == appObject.userProfile.id }) {
                        Button("Join") {
                            Task {
                                await joinPool()
                            }
                        }
                    } else if pool.admin_id == appObject.userProfile.id || pool.is_public {
                        ShareLink("Invite", item:  DeepLink.build(action: .joinPool, params: [URLQueryItem(name: "id", value: pool.id.uuidString)]))
                    }
                }
                List(poolObject.entries) { e in
                    HStack {
                        Text(e.profile?.username ?? "")
                        Spacer()
                        Text(e.complete ? "Complete" : "Incomplete")
                    }.onTapGesture {
                        showEntry = e
                    }
                }
            }
            Spacer()
        }
        .padding(30)
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

#Preview {
    PoolPage(pool: Pool(id: UUID(), created_at: Date(), admin_id: UUID(), event_id: UUID(), title: "Test Pool", pool_type: "golf-pick-six", is_public: false))
}
