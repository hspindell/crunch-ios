//
//  GolfPoolLeaderboard.swift
//  Crunch
//
//  Created by Henry Spindell on 5/21/24.
//

import SwiftUI
import Supabase

struct PGATournamentState: Codable {
    var status: String
    var leaderboard: [String : GolferTournamentResult]
}

struct GolferTournamentResult: Codable {
    var golferId: String
    var golferStatus: String // TODO enum
    var place: Int
    var score: String
    var adjustedScore: Int
    
    var scoreDisplay: String {
        if golferStatus == "WITHDRAWN" || golferStatus == "CUT" {
            return "\(score) (\(golferStatus))"
        }
        return score
    }
}

struct GolfPickSixEntryResult {
    var entryId: String
    var sumAdjustedScore: Int
    var topGolferIds: [String]
    
    var adjustedScoreDisplay: String {
        if sumAdjustedScore == 0 {
            return "E"
        } else if sumAdjustedScore > 0 {
            return "+\(sumAdjustedScore)"
        } else {
            return sumAdjustedScore.description
        }
    }
}

struct GolfPoolLeaderboard: View {
    @EnvironmentObject var gpoolObject: PoolObject
    var event: Event
    @Binding var selectedEntry: Entry?
    
    @State var leaderboard = [String : GolferTournamentResult]()
    @State var orderedEntries = [(Entry, GolfPickSixEntryResult)]()
    
    var poolObject: GolfPoolObject {
        gpoolObject as! GolfPoolObject
    }
    
    func fetchLeaderboard() async {
        guard let tournamentId = event.external_id else { return }
        do {
            let response: PGATournamentState = try await supabase.functions
              .invoke("fetch-pga-leaderboard", // TODO put functions in enum
                options: FunctionInvokeOptions(
                    body: ["tournamentId": tournamentId]
                )
              )
            leaderboard = response.leaderboard
            
            let entryResults: [(Entry, GolfPickSixEntryResult)] = poolObject.entries.compactMap { entry in
                guard entry.complete, let picks = (entry.picks?.value as? [String]) else { return nil }
                let picksResults = picks.compactMap { golferId in
                    return response.leaderboard[String(golferId)]
                }
                let topX = picksResults.sorted(by: { a, b in a.adjustedScore < b.adjustedScore }).prefix(upTo: min(4, picksResults.count))
                let topXIds = topX.map(\.golferId) + Array(repeating: "", count: max(4 - topX.count, 0))
                return (entry, GolfPickSixEntryResult(entryId: entry.id,
                                              sumAdjustedScore: topX.map(\.adjustedScore).reduce(0, +),
                                              topGolferIds: topXIds))
            }
            
            orderedEntries = entryResults.sorted(by: { a, b in
                a.1.sumAdjustedScore < b.1.sumAdjustedScore
            })
        } catch {
            print("fetchLeaderboard: \(error.localizedDescription)")
        }
    }
    
    var body: some View {
        ScrollView {
            Divider()
            ForEach(orderedEntries, id: \.0.id) { entry, entryResult in
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text(entry.profile?.username ?? entry.title)
                        Spacer()
                        Text(entryResult.adjustedScoreDisplay)
                    }
                    .padding(top: 8, leading: 8, bottom: 0, trailing: 8)
                    .font(.system(size: 14, weight: .semibold))
                    
                    Divider()
                        .background(Color.white)
                        .foregroundStyle(Color.white)
                        .padding(top: 4)
                    
                    HStack(spacing: 0) {
                        ForEach(entryResult.topGolferIds, id: \.self) { golferId in
                            if let golfer = poolObject.golfersById[golferId] {
                                GolferLeaderboardDisplay(golfer: golfer, scoreDisplay: leaderboard[golferId]?.scoreDisplay ?? "??")
                            } else {
                                GolferLeaderboardDisplay(scoreDisplay: "N/A")
                            }
                        }
                        // TODO ensure 4 slots are filled
                    }
                }
                .background(Color.black)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .foregroundStyle(Color.white)
                .padding(top: 10)
                .onTapGesture {
                    selectedEntry = poolObject.entries.first(where: { $0.id == entryResult.entryId })
                }
            }
        }
        .task {
            await fetchLeaderboard()
        }
    }
}

#Preview {
    GolfPoolLeaderboard(event: Event.sample, selectedEntry: .constant(nil))
}
