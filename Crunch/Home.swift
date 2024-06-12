//
//  Home.swift
//  Crunch
//
//  Created by Henry Spindell on 4/18/24.
//

import SwiftUI
import FirebaseAuth
import PostgREST


// TODO: abstract queries/DB operations to a singleton
// TODO: map between snake case and camel somehow?
// TODO: decide how to treat models when they have different properties depending on query context e.g. profile along w entry

struct Home: View {
    @EnvironmentObject var authObject: AuthStateObject
    @EnvironmentObject var appObject: AppObject
    
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
                  *, profiles_circles!inner(profile_id)
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
                  *, pool:pool_id(*)
                  """
                )
                .eq("profile_id", value: appObject.userProfile.id)
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

        VStack(alignment: .leading) {
            HStack {
                Text("My Pools")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button("Find pool") {
                    showFindPool = true
                }
                Text("/")
                Button("Start pool") {
                    showCreatePool = true
                }
            }
            List(myEntries) { e in
                Text(e.pool.title)
                    .onTapGesture {
                        selectedPool = e.pool
                    }
            }
            
            Spacer(minLength: 50)
            
            HStack {
                Text("My Circles")
                    .font(.title2)
                Spacer()
                Button("Create circle") {
                    showCreateCircle = true
                }
            }
            List(appObject.circles, id: \.title) { c in
                HStack {
                    Text(c.title)
                    Spacer()
                    if (c.owner_id == appObject.userProfile.id) {
                        Text("Admin")
                    }
                }.onTapGesture {
                    selectedCircle = c
                }
            }
            
            Spacer(minLength: 50)
            
            HStack {
                Text(appObject.userProfile.username)
                Spacer()
                Button("Sign out", role: .destructive) {
                    Task { await authObject.signOut() }
                }
            }
        }
        .padding(30)
        .ignoresSafeArea()
        .background(Color.black)
        .foregroundStyle(Color.white)
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
            CreatePoolPage(allowCircleChange: true)
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
    }
}

#Preview {
    Home()
        .environmentObject(AppObject(userProfile: Profile.sample))
}
