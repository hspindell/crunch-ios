//
//  GolfPickSix.swift
//  Crunch
//
//  Created by Henry Spindell on 5/15/24.
//

import SwiftUI

struct PickSixUpdate : Codable {
    var picks: [String?]
    var complete: Bool
}

struct GolfPickSix: View {
    @EnvironmentObject var appObject: AppObject
    @EnvironmentObject var poolObject: PoolObject
    
    var golfPoolObject: GolfPoolObject {
        poolObject as! GolfPoolObject
    }

    var event: Event
    @State var golfersByTier = [[Golfer]]()
    @State var selectionsByTier = [Int : Golfer]()
    @State var currentTier = 0
    let tierSize = 10
    @State var entry: Entry
    
    var isMyEntry: Bool {
        entry.profile_id == appObject.userProfile.id
    }
    
    var viewable: Bool {
        isMyEntry || event.started
    }

    var editable: Bool {
        isMyEntry && !event.started
    }
    
    func fetchGolfers() {
        var allGolfers = golfPoolObject.topGolfers
        if allGolfers.count < 51 { return }
        // first 5 tiers are 10 golfers each
        while golfersByTier.count < 5 {
            let tier = Array(allGolfers.prefix(upTo: tierSize))
            golfersByTier.append(tier)
            allGolfers = Array(allGolfers.dropFirst(tierSize))
        }
        golfersByTier.append(allGolfers) // last tier is whoever is left
        
        // populate selections
        if let picks = (entry.picks?.value as? [String?]) {
            for (tier, golferId) in picks.enumerated() {
                selectionsByTier[tier] = golfersByTier[tier].first(where: { $0.id == golferId })
            }
            currentTier = picks.firstIndex(where: { $0 == nil }) ?? 0
        }
    }
    
    func savePicks() async {
        let selectionsInOrder = stride(from: 0, to: 6, by: 1).map { i in
            selectionsByTier[i]?.id
        }

        let completedPicks = selectionsInOrder.count == 6 && selectionsInOrder.allSatisfy({$0 != nil})
        
        do {
            entry = try await supabase.from("entries")
                .update(PickSixUpdate(picks: selectionsInOrder, complete: completedPicks))
                .match(["profile_id": appObject.userProfile.id,
                        "pool_id": entry.pool_id])
                .select()
                .single()
                .execute()
                .value
        } catch {
            print(error.localizedDescription)
        }
    }
    
    var body: some View {
        VStack(spacing: 15) {
            Text("In this format, participants choose one golfer in each of six tiers, determined by the Official World Golf Ranking prior to the event's start. The entry's score will be the sum of the four best golfer's scores. Golfers are assigned a score of +8 for each round they fail to complete.")
                .font(.system(size: 12))
                .messageBox()
            
            VStack(spacing: 0) {
                GolfPickSixSelections(selectionsByTier: selectionsByTier, viewable: viewable, currentTier: $currentTier)
                
                if viewable {
                    HStack {
                        Spacer()
                        Button("<") {
                            currentTier -= 1
                        }
                        .tint(Color.white)
                        .fontWeight(.bold)
                        
                        .disabled(currentTier == 0)
                        Text("Tier \(currentTier+1)")
                            .font(.system(size: 14, weight: .semibold))
                            .padding(h: 10)
                            .highlighted(Color.white)
                            .padding(h: 10)
                        Button(">") {
                            currentTier += 1
                        }
                        .tint(Color.white)
                        .fontWeight(.bold)
                        .disabled(currentTier == golfersByTier.endIndex-1)
                        Spacer()
                    }
                    .padding(top: 15, bottom: 8)
                }

                if editable {
                    if currentTier < golfersByTier.endIndex {
                        VStack(spacing: 0) {
                            ForEach(golfersByTier[currentTier]) { g in
                                GolferListItem(golfer: g, selected: selectionsByTier[currentTier]?.id == g.id)
                                    .onTapGesture {
                                        selectionsByTier[currentTier] = g
                                        Task {
                                            await savePicks()
                                        }
                                        
                                        // select next tier without a pick, preferring going up
                                        var nextTier = (currentTier + 1) % 6
                                        while nextTier != currentTier {
                                            if selectionsByTier[nextTier].isNil {
                                                currentTier = nextTier
                                                break
                                            }
                                            nextTier = (nextTier + 1) % 6
                                        }
                                    }
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    } else {
                        Text("Loading...")
                    }
                }
            }
            .padding(15)
            .background(StripeBGDark())
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .onChange(of: golfPoolObject.topGolfers) { oldValue, newValue in
            fetchGolfers()
        }
        .onAppear {
            fetchGolfers()
        }
    }
}

#Preview {
    GolfPickSix(event: Event(id: UUID(), title: "My event", starts_at: Date()), entry: Entry(profile_id: UUID(), pool_id: UUID(), complete: false, title: "banana"))
        .environmentObject(AppObject.sample)
        .environmentObject(GolfPoolObject(pool: Pool.sample))
        .environmentObject(PoolObject(pool: Pool.sample))
}
