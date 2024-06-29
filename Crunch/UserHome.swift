//
//  UserHome.swift
//  Crunch
//
//  Created by Henry Spindell on 5/24/24.
//

import SwiftUI

struct UserHome: View {
    @EnvironmentObject var appObject: AppObject
    @EnvironmentObject var authObject: AuthStateObject
    
    @State var myEntries = [MyEntryOverview]()
    @State var showFindPool = false
    @State var showCreatePool = false
    @State var selectedPool: Pool?
    
    @State var showCreateCircle = false
    @State var selectedCircle: CrCircle?
    
    private func dismissAllModals() {
        showFindPool = false
        showCreatePool = false
        showCreateCircle = false
        selectedCircle = nil
        selectedPool = nil
    }
    
    private func fetchCircle(id: String) async -> CrCircle? {
        do {
            return try await supabase
                .from("circles")
                .select()
                .eq("id", value: id)
                .single()
                .execute()
                .value
        } catch {
            print("fetchCircle by ID: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func fetchPool(id: String) async -> Pool? {
        do {
            return try await supabase
                .from("pools")
                .select()
                .eq("id", value: id)
                .single()
                .execute()
              .value
        } catch {
            print("fetchPool by ID: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func fetchCircles() async {
        do {
            let result: [CrCircle] = try await supabase
                .from("circles")
                .select(
                  """
                  *, profiles_circles!inner(profile_id), owner:owner_id(*)
                  """
                )
                .eq("profiles_circles.profile_id", value: appObject.userProfile.id)
                .execute()
                .value
            await MainActor.run {
                appObject.circles = result
            }
        } catch {
            print("fetchCircles: \(error.localizedDescription)")
        }
    }
    
    private func fetchEntries() async {
        do {
            let result: [MyEntryOverview] = try await supabase
                .from("entries")
                .select(
                  """
                  *, pool:pool_id(*, events(*))
                  """
                )
                .eq("profile_id", value: appObject.userProfile.id)
                .order("created_at", ascending: false)
                .execute()
                .value
            
            await MainActor.run {
                myEntries = result
            }
        } catch {
            print("fetchEntries: \(error.localizedDescription)")
        }
    }
    
    private func onPageAppear() {
        Task {
            await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask { await fetchCircles() }
                group.addTask { await fetchEntries() }
            }
        }
    }
    
    @discardableResult private func consumePoolLink(id: String) async -> Bool {
        if let pool = await fetchPool(id: id) {
            await MainActor.run {
                dismissAllModals()
                selectedPool = pool
                appObject.clearDeepLinks()
            }
            return true
        }
        return false
    }
    
    @discardableResult private func consumeCircleLink(id: String) async -> Bool {
        if let circle = await fetchCircle(id: id) {
            await MainActor.run {
                dismissAllModals()
                selectedCircle = circle
                appObject.clearDeepLinks()
            }
            return true
        }
        return false
    }
    
    private func consumeDeepLinkIfAvailable() async {
        if let poolId = appObject.deepLinkPoolId, await consumePoolLink(id: poolId) {
            return
        }
        if let circleId = appObject.deepLinkCircleId, await consumeCircleLink(id: circleId) {
            return
        }
    }
    

    
    var body: some View {
        ScrollView {
            ZStack(alignment: .top) {
                // Want top to be black even if user pulls down on the scroll view
                Rectangle()
                    .fill(Color.black)
                    .frame(height: 600)
                    .offset(y: -400)
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("My Pools")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(Color.white)
                        Spacer()
                    }
                    EntriesList(pools: myEntries.map(\.pool), 
                                includePublicCard: true,
                                includeCreateCard: true,
                                selectedPool: $selectedPool,
                                showFindPool: $showFindPool,
                                showCreatePool: $showCreatePool)
                    .padding(h: -30)
                    
                    Text("My Circles")
                        .font(.system(size: 28, weight: .semibold))
                        .padding(.top, 30)
                    VStack(spacing: 15) {
                        ForEach(appObject.circles) { circle in
                            CircleCard(circle: circle)
                                .onTapGesture {
                                    selectedCircle = circle
                                }
                        }
                        CircleCard()
                            .onTapGesture {
                                showCreateCircle = true
                            }
                    }.padding(bottom: 50)
                    
                    Spacer()

                }
                .padding(15)
            }
        }
        .background(StripeBG())
        .overlay(alignment: .bottom) {
            HStack {
                Text(appObject.userProfile.username)
                Spacer()
                Button("Sign out", role: .destructive) {
                    Task { await authObject.signOut() }
                }
            }
            .font(.system(size: 12))
            .padding(h: 15)
        }
        .fullScreenCover(item: $selectedCircle, onDismiss: onPageAppear) { circle in
            CirclePage(circle: circle)
        }
        .fullScreenCover(item: $selectedPool, onDismiss: onPageAppear) { pool in
            PoolPage(pool: pool)
        }
        .fullScreenCover(isPresented: $showFindPool, onDismiss: onPageAppear) {
            PublicPoolsPage(existingPools: myEntries.map(\.pool))
        }
        .fullScreenCover(isPresented: $showCreateCircle, onDismiss: onPageAppear) {
            CreateCirclePage()
        }
        .fullScreenCover(isPresented: $showCreatePool, onDismiss: onPageAppear) {
            CreatePoolFlow()
        }
        .onChange(of: appObject.deepLinkPoolId) { oldValue, newValue in
            Task {
                if let newValue {
                    await consumePoolLink(id: newValue)
                }
            }
        }
        .onChange(of: appObject.deepLinkCircleId) { oldValue, newValue in
            Task {
                if let newValue {
                    await consumeCircleLink(id: newValue)
                }
            }
        }
        .onAppear {
            onPageAppear()
            Task { await consumeDeepLinkIfAvailable() }
        }
        .task {
            await fetchEntries()
        }
    }
}

#Preview {
    UserHome()
        .environmentObject(AppObject.sample)
}
