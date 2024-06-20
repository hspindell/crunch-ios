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
    
    var userIsCircleAdmin: Bool {
        circle.owner_id == appObject.userProfile.id
    }
    
    private func joinCircle() async {
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
    
    private func fetchMembers() async {
        do {
            let result: [Profile] = try await supabase
                .from("profiles")
                .select(
                  """
                  *, profiles_circles!inner(*)
                  """
                )
                .eq("profiles_circles.circle_id", value: circle.id)
                .order("created_at", ascending: false, referencedTable: "profiles_circles")
                .execute()
              .value
            await MainActor.run {
                members = result
            }
        } catch {
            print("fetchMembers: \(error.localizedDescription)")
        }
    }
    
    private func fetchPools() async {
        do {
            let result: [Pool] = try await supabase
                .from("pools")
                .select("*, events!inner(*)")
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
    
    private func fetchMyEntries() async {
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
    
    private func onPageAppear() {
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
                Text(circle.title)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.white)
                    
                Spacer()
                CloseButton()
            }
            .contentShape(Rectangle())
            .padding(h: 15, v: 8)
            .background(StripeBGDark(reverse: true))

            VStack(alignment: .leading, spacing: 10) {
                // TODO separate active and historical pools
                HStack {
                    Text("Pools")
                        .font(.system(size: 18, weight: .semibold))
                    Spacer()
                    if userIsCircleAdmin {
                        JoinButton(text: "Create pool").onTapGesture {
                            showCreatePool = true
                        }
                    }
                }.padding(top: 15)
                Divider()
                
                if pools.isEmpty {
                    Text("There are no active pools in this circle. \(userIsCircleAdmin ? "" : " Only the circle admin may create pools.")")
                        .font(.system(size: 12))
                        .padding(top: 10)
                } else {
                    EntriesList(pools: pools, selectedPool: $selectedPool, showFindPool: .constant(false), showCreatePool: $showCreatePool)
                        .padding(h: -15)
                }
                
                
                // TODO indicator of if we have an entry & whether it is complete?
                
                Spacer(minLength: 30)
                
                HStack {
                    Text("Members")
                        .font(.system(size: 18, weight: .semibold))
                    Spacer()
                    
                    if !members.contains(where: { $0.id == appObject.userProfile.id }) {
                        JoinButton().onTapGesture {
                            Task { await joinCircle() }
                        }
                    } else if userIsCircleAdmin {
                        ShareLink(item: DeepLink.build(action: .joinCircle, params: [URLQueryItem(name: "id", value: circle.id.uuidString)])) {
                            InviteButton()
                        }
                    }
                }
                Divider()
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        ForEach(members, id: \.username) { m in
                            Text(m.username)
                                .font(.system(size: 14, weight: .semibold))
                                .padding(h: 4)
                                .highlighted()
                                .padding(leading: 8)
                        }
                    }
                }
            }.padding(h: 15)
        }
        .background(StripeBG())
        .fullScreenCover(isPresented: $showCreatePool, onDismiss: onPageAppear) {
            CreatePoolFlow(circle: circle)
        }
        .fullScreenCover(item: $selectedPool, onDismiss: onPageAppear) { pool in
            PoolPage(pool: pool)
        }
        .onAppear(perform: onPageAppear)
    }
}

#Preview {
    CirclePage(circle: CrCircle.sample)
        .environmentObject(AppObject.sample)
}
