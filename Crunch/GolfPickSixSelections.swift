//
//  GolfPickSixSelections.swift
//  Crunch
//
//  Created by Henry Spindell on 6/17/24.
//

import SwiftUI

struct GolfPickSixSelections: View {
    var selectionsByTier: [Int : Golfer]
    var viewable: Bool
    @Binding var currentTier: Int
    
    private func golferAtTier(_ tier: Int) -> Golfer? {
        if viewable == false {
            return .obscured
        }
        return selectionsByTier[tier] ?? .obscured
    }
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 0), count: 3), spacing: 0) {
            ForEach(0..<6) { i in
                GolferLeaderboardDisplay(golfer: golferAtTier(i), scoreDisplay: viewable ? (golferAtTier(i)?.last_name ?? "-") : "?", leaderboard: false, selected: currentTier == i)
                    .border((viewable && currentTier == i) ? Color.crunchYellow : Color.black, width: 2)
                    .onTapGesture {
                        currentTier = i
                    }
            }
        }
        .background(Color.white.opacity(0.15))
    }
}

#Preview {
    ZStack {
        StripeBGDark()
        GolfPickSixSelections(selectionsByTier: [1: .sample, 2: .sample], viewable: true, currentTier: .constant(1))
            .frame(height: 300)
            
    }

}
