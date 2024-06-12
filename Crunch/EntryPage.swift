//
//  EntryPage.swift
//  Crunch
//
//  Created by Henry Spindell on 5/15/24.
//

import SwiftUI

struct Golfer: Codable, Identifiable, Equatable {
    var id: String { pga_id }
    
    var pga_id: String
    var first_name: String
    var last_name: String
    var rank: Int
    var avatar_url: String?
    var avatarURL: URL? { avatar_url?.url }
    var country: String
    
    static let flagCodeMapping = [
        "ARG": "ar",
        "AUS": "au",
        "AUT": "at",
        "BEL": "be",
        "CAN": "ca",
        "CHI": "cl",
        "DEN": "dk",
        "ENG": "gb-eng",
        "ESP": "es",
        "FIN": "fi",
        "FRA": "fr",
        "GER": "de",
        "IRL": "ie",
        "JPN": "jp",
        "KOR": "kr",
        "NIR": "gb-nir",
        "NOR": "no",
        "NZL": "nz",
        "POL": "pl",
        "RSA": "za",
        "SCO": "gb-sct",
        "SWE": "se",
        "USA": "us",
    ]
    
    var flagCode: String? {
        Self.flagCodeMapping[country]
    }
}

struct EntryPage: View {
    @EnvironmentObject var appObject: AppObject
    @Environment(\.dismiss) var dismiss
    var pool: Pool
    var entry: Entry
    var event: Event
    
    var body: some View {
        ZStack {
            if entry.complete {
                Color.green
            } else if !event.started {
                Color.yellow
            } else {
                Color.red
            }
            VStack(alignment: .leading) {
                Button("Back") {
                    dismiss()
                }
                // TODO allow edit title if entry owner
                Text(entry.title)
                    .font(.title)
                Text(entry.complete ? "Complete" : "Incomplete")
                    .font(.title3)
                Text(pool.title)
                    .font(.title3)
                Text("\(event.title) (\(pool.pool_type))")
                    .font(.title3)
                Spacer()
                switch pool.poolType {
                case .golfPickSix:
                    GolfPickSix(event: event, entry: entry)
                case .none:
                    Text("This pool type is not yet supported. Try updating from the App Store.")
                }

                Spacer()
            }
            .padding(30)
        }


    }
}

// TODO sample data
//#Preview {
//    EntryPage(entry: Entry(profile_id: UUID(), pool_id: UUID(), complete: false, title: "My Entry"))
//}
