//
//  CirclePage.swift
//  Crunch
//
//  Created by Henry Spindell on 5/7/24.
//

import SwiftUI

struct CirclePage: View {
    @EnvironmentObject var appObject: AppObject
    @Environment(\.dismiss) var dismiss
    var circle: CrCircle
    @State var members = [Profile]()
    @State var pools = [Pool]()
    @State var entries = [Entry]()
    @State var showCreatePool = false
    @State var selectedPool: Pool?
    
    func joinCircle() async {
        do {
            try await supabase
                .from("profiles_circles")
                .insert(["circle_id": circle.id])
                .execute()
                .value
            var copy = members
            copy.append(appObject.userProfile)
            members = copy
        } catch {
            print("joinCircle: \(error.localizedDescription)")
        }
    }
    
    func fetchMembers() async {
        do {
            let result: [Profile] = try await supabase
                .from("profiles")
                .select(
                  """
                  *, profiles_circles!inner(*)
                  """
                )
                .eq("profiles_circles.circle_id", value: circle.id)
                .execute()
              .value
            await MainActor.run {
                members = result
            }
        } catch {
            print("fetchMembers: \(error.localizedDescription)")
        }
    }
    
    func fetchPools() async {
        do {
            let result: [Pool] = try await supabase
                .from("pools")
                .select()
                .eq("circle_id", value: circle.id)
                .execute()
              .value
            await MainActor.run {
                pools = result
            }
        } catch {
            print("fetchPools: \(error.localizedDescription)")
        }
    }
    
    func fetchMyEntries() async {
        do {
            let result: [Entry] = try await supabase
                .from("entries")
                .select()
                .eq("profile_id", value: appObject.userProfile.id)
                .in("pool_id", values: pools.map(\.id))
                .execute()
              .value
            await MainActor.run {
                entries = result
            }
        } catch {
            print("fetchMyEntries: \(error.localizedDescription)")
        }
    }
    
    func onPageAppear() {
        Task {
            await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask { await fetchMembers() }
                group.addTask { await fetchPools() }
                group.addTask { await fetchMyEntries() }
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button("Back") {
                    dismiss()
                }
                Spacer()
            }

            Text(circle.title)
                .font(.title)
            
            Spacer()

            HStack {
                Text("Pools")
                    .font(.title2)
                Spacer()
                Button("Create pool") {
                    showCreatePool = true
                }
            }
            List(pools, id: \.title) { p in
                Text("\(p.title) (\(entries.contains(where: { $0.pool_id == p.id }) ? "Entered" : "Not entered"))")
                    .onTapGesture {
                        selectedPool = p
                    }
            }

            Spacer(minLength: 50)
            
            HStack {
                Text("Members")
                    .font(.title2)
                Spacer()
                
                if !members.contains(where: { $0.id == appObject.userProfile.id }) {
                    Button("Join") {
                        Task { await joinCircle() }
                    }
                } else if circle.owner_id == appObject.userProfile.id {
                    ShareLink("Invite", item:  DeepLink.build(action: .joinCircle, params: [URLQueryItem(name: "id", value: circle.id.uuidString)]))
                }
            }
            List(members, id: \.username) { m in
                Text(m.username)
            }
        }
        .padding(30)
        .fullScreenCover(isPresented: $showCreatePool, onDismiss: onPageAppear) {
            CreatePoolPage(circle: circle)
        }
        .fullScreenCover(item: $selectedPool, onDismiss: onPageAppear) { pool in
            PoolPage(pool: pool)
        }
        .onAppear(perform: onPageAppear)
    }
}

#Preview {
    CirclePage(circle: CrCircle(id: UUID(), created_at: Date(), title: "My Circle", owner_id: UUID()))
}
