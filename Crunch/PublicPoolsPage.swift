//
//  PublicPoolsPage.swift
//  Crunch
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
    
    private let cardColors: [Color] = [.crunchYellow, .crunchCyan, .crunchPurple]
    
    private func cardColor(forIndex index: Int) -> Color {
        cardColors[index % cardColors.count]
    }
    
    private func fetchAvailable() async {
        do {
            let result: [Pool] = try await supabase
                .from("pools")
                .select("*, events!inner(*)")
                .eq("is_public", value: true)
                .greaterThanOrEquals("events.starts_at", value: Date().ISO8601Format())
                .order("starts_at", ascending: true, referencedTable: "events")
                .execute()
              .value
            await MainActor.run {
                pools = result
            }
        } catch {
            print("fetchAvailable: \(error.localizedDescription)")
        }
    }
    
    private func userHasJoined(pool: Pool) -> Bool {
        existingPools.contains(where: { $0.id == pool.id })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Join a public pool")
                    .font(.system(size: 20, weight: .semibold))
                    .padding(h: 15, v: 2)
                    .leadingHighlight(Color.white)
                    
                Spacer()
                CloseButton()
            }.padding(leading: -15)

            Divider()
                .padding(top: 10)
            
            ScrollView {
                VStack(spacing: 10) {
                    if let unjoinedPools = pools.filter({ !userHasJoined(pool: $0) }).presence {
                        ForEach(Array(unjoinedPools.enumerated()), id: \.0) { idx, p  in
                            PublicPoolListItem(pool: p, cardColor: cardColor(forIndex: idx))
                            .onTapGesture {
                                selectedPool = p
                            }
                        }
                    } else {
                        Text("No joinable pools found.")
                    }
                }.padding(v: 15)
            }
        }
        .fullScreenCover(item: $selectedPool) { pool in
            PoolPage(pool: pool)
        }
        .padding(15)
        .background(StripeBG())
        .task {
            await fetchAvailable()
        }
    }
}

#Preview {
    PublicPoolsPage(existingPools: [])
}
