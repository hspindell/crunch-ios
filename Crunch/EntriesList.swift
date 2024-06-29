//
//  EntriesList.swift
//  Crunch
//
//  Created by Henry Spindell on 6/12/24.
//

import SwiftUI

struct EntriesList: View {
    var pools: [Pool]
    var includePublicCard = false
    var includeCreateCard = false
    @Binding var selectedPool: Pool?
    @Binding var showFindPool: Bool
    @Binding var showCreatePool: Bool
    
    private var activePools: [Pool] {
        pools.filter { $0.concluded == false }
    }
    
    private var concludedPools: [Pool] {
        pools.filter(\.concluded)
    }
    
    private let cardColors: [Color] = [.crunchYellow, .crunchCyan, .crunchPurple]
    
    private func cardColor(forIndex index: Int) -> Color {
        cardColors[index % cardColors.count]
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(Array(activePools.enumerated()), id: \.offset) { index, pool in
                    PoolCard(pool: pool, backgroundColor: cardColor(forIndex: index))
                        .padding(top: 1) // TODO hack to fix offset clipping for now (something to do with padding)
                        .onTapGesture {
                            selectedPool = pool
                        }
                }
                
                if includePublicCard {
                    PoolCard(title: "Join Pool", backgroundColor: .crunchOrange)
                        .padding(top: 1)
                        .onTapGesture {
                            showFindPool = true
                        }
                }

                if includeCreateCard {
                    PoolCard(title: "Start Pool", backgroundColor: .crunchGreen)
                        .padding(top: 1)
                        .onTapGesture {
                            showCreatePool = true
                        }
                }
                
                ForEach(Array(concludedPools.enumerated()), id: \.offset) { index, pool in
                    PoolCard(pool: pool, backgroundColor: .gray.tint(30))
                        .padding(top: 1) // TODO hack to fix offset clipping for now (something to do with padding)
                        .onTapGesture {
                            selectedPool = pool
                        }
                }
            }
            .padding(leading: 30, bottom: 7, trailing: 30)
        }
    }
}

//#Preview {
//    EntriesList()
//}
