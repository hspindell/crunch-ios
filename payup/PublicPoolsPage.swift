//
//  PublicPoolsPage.swift
//  payup
//
//  Created by Henry Spindell on 5/8/24.
//

import SwiftUI

struct PublicPoolsPage: View {
    @EnvironmentObject var appObject: AppObject
    @Environment(\.dismiss) var dismiss
    var existingPools: [Pool]
    @State var pools = [Pool]()
    @State var selectedPool: Pool?
    
    func fetchAvailable() async {
        do {
            let result: [Pool] = try await supabase
                .from("pools")
                .select()
                .eq("is_public", value: true)
                .execute()
              .value
            await MainActor.run {
                pools = result
            }
        } catch {
            print("fetchAvailable: \(error.localizedDescription)")
        }
    }
    
    func userHasJoined(pool: Pool) -> Bool {
        existingPools.contains(where: { $0.id == pool.id })
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Button("Back") {
                dismiss()
            }
            Text("Public Pools")
                .font(.title)
            List(pools.filter({ !userHasJoined(pool: $0) }), id: \.title) { p in
                Text(p.title).onTapGesture {
                    selectedPool = p
                }
            }
            Spacer()
        }
        .fullScreenCover(item: $selectedPool) { pool in
            PoolPage(pool: pool)
        }
        .padding(30)
        .task {
            await fetchAvailable()
        }
    }
}

#Preview {
    PublicPoolsPage(existingPools: [])
}
