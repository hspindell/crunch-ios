//
//  GolfPoolLeaderboard.swift
//  payup
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
                guard entry.complete, let picks = (entry.picks?.value as? [Int]) else { return nil }
                let picksResults = picks.compactMap { golferId in
                    return response.leaderboard[String(golferId)]
                }
                let topX = picksResults.sorted(by: { a, b in a.adjustedScore < b.adjustedScore }).prefix(upTo: min(4, picksResults.count))
                return (entry, GolfPickSixEntryResult(entryId: entry.id,
                                              sumAdjustedScore: topX.map(\.adjustedScore).reduce(0, +),
                                              topGolferIds: topX.map(\.golferId)))
            }
            
            orderedEntries = entryResults.sorted(by: { a, b in
                a.1.sumAdjustedScore < b.1.sumAdjustedScore
            })
        } catch {
            print("fetchLeaderboard: \(error.localizedDescription)")
        }
    }
    
    var body: some View {
        VStack {
            List(orderedEntries, id: \.0.id) { entry, entryResult in
                VStack(alignment: .leading) {
                    HStack {
                        Text(entry.profile?.username ?? entry.title)
                        Spacer()
                        Text(entryResult.sumAdjustedScore.description)
                    }
                    .fontWeight(.bold)
                    HStack {
                        ForEach(entryResult.topGolferIds, id: \.self) { golferId in
                            VStack {
                                ZStack {
                                    if let flagCode = poolObject.golfersById[golferId]?.flagCode {
                                        Image(flagCode)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 30, height: 30)
                                    }
                                    AsyncImage(url: poolObject.golfersById[golferId]?.avatarURL) { result in
                                        result.image?
                                            .resizable()
                                            .scaledToFit()
                                    }
                                }

                                Text(poolObject.golfersById[golferId]?.last_name ?? golferId)
                                    .fontWeight(.semibold)
                                Text(leaderboard[golferId]?.scoreDisplay ?? "??")
                            }
                            Spacer()
                        }
                    }
                    .font(.caption)
                }
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
    GolfPoolLeaderboard(event: Event(id: UUID(), title: "", starts_at: Date()), selectedEntry: .constant(nil))
}
