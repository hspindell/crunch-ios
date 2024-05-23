//
//  GolfPickSix.swift
//  payup
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
        VStack {
            Divider()
            HStack {
                ForEach(0..<3) { i in
                    Text(viewable ? (selectionsByTier[i]?.last_name ?? "–") : "???")
                        .fontWeight(.bold)
                    Spacer()
                }
            }
            HStack {
                ForEach(3..<6) { i in
                    Text(viewable ? (selectionsByTier[i]?.last_name ?? "–") : "???")
                        .fontWeight(.bold)
                    Spacer()
                }
            }
            Divider()

            if isMyEntry && !event.started {
                Text("Event has not started; you may edit your selections until \(event.starts_at.formatted(.dateTime.weekday(.wide).month().day().hour().minute().timeZone())).")
            } else if !isMyEntry && !event.started {
                Text("You may view other users' entries once the event has started (\(event.starts_at.formatted(.dateTime.weekday(.wide).month().day().hour().minute().timeZone()))).")
            } else if isMyEntry && event.started {
                Text("Event has started; your entry can only be modified by the pool admin.")
            }
            
            
            if editable {
                if currentTier < golfersByTier.endIndex {
                    List(golfersByTier[currentTier]) { g in
                        Text("\(g.rank): \(g.last_name)")
                            .fontWeight(selectionsByTier[currentTier]?.id == g.id ? .bold : .regular)
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
                } else {
                    Text("Loading...")
                }
                HStack {
                    Button("<") {
                        currentTier -= 1
                    }
                    .disabled(currentTier == 0)
                    Text("Tier \(currentTier+1)")
                    Button(">") {
                        currentTier += 1
                    }
                    .disabled(currentTier == golfersByTier.endIndex-1)
                }
            }
            Spacer()
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
}
