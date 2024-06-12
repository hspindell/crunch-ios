//
//  EntriesList.swift
//  Crunch
//
//  Created by Henry Spindell on 6/12/24.
//

import SwiftUI

struct EntriesList: View {
    var entries: [MyEntryOverview]
    @Binding var selectedPool: Pool?
    @Binding var showFindPool: Bool
    @Binding var showCreatePool: Bool
    
    private let cardColors: [Color] = [.crunchYellow, .crunchCyan, .crunchPurple]
    
    private func cardColor(forIndex index: Int) -> Color {
        cardColors[index % cardColors.count]
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(Array(entries.enumerated()), id: \.offset) { index, entry in
                    PoolCard(entry: entry, backgroundColor: cardColor(forIndex: index))
                        .onTapGesture {
                            selectedPool = entry.pool
                        }
                }
                PoolCard(title: "Join Pool", backgroundColor: .crunchOrange)
                    .onTapGesture {
                        showFindPool = true
                    }
                PoolCard(title: "Start Pool", backgroundColor: .crunchGreen)
                    .onTapGesture {
                        showCreatePool = true
                    }
            }
            .padding(leading: 30, bottom: 7, trailing: 30)
        }
        .padding(h: -30)
    }
}

//#Preview {
//    EntriesList()
//}
