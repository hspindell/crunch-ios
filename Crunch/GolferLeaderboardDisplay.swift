//
//  GolferLeaderboardDisplay.swift
//  Crunch
//
//  Created by Henry Spindell on 6/15/24.
//

import SwiftUI

struct GolferLeaderboardDisplay: View {
    var golfer: Golfer?
    var scoreDisplay: String
    var nametag = true
    var selected = false
    
    private var fontColor: Color {
        if selected {
            return .crunchYellow
        } else if scoreDisplay.starts(with: "-") {
            return .crunchGreen
        } else if scoreDisplay.starts(with: "+") {
            return .crunchOrange
        } else {
            return .white
        }
    }
    
    var body: some View {
        VStack {
            AsyncImage(url: golfer?.avatarURL, content: { img in
                img.resizable().scaledToFit()
            }, placeholder: {
                Image("silhouette")
                    .resizable()
                    .scaledToFit()
            })
            .background(
                Color.clear.overlay {
                    if let flagCode = golfer?.flagCode {
                        Image(flagCode)
                            .resizable()
                            .scaledToFill()
                    }
                }.clipped()
            )
            .overlay(alignment: .bottomTrailing) {
                Text(scoreDisplay)
                    .padding(6)
                    .trailingHighlight(.black.opacity(0.85))
                    .foregroundStyle(fontColor)
                    .font(.system(size: 12, weight: .bold))
            }
            if nametag, let lastName = golfer?.last_name {
                Text(lastName)
                    .font(.system(size: 12, weight: .semibold))
                    .lineLimit(1)
                    .padding(bottom: 8)
            }
        }
    }
}

#Preview {
    HStack {
        GolferLeaderboardDisplay(golfer: Golfer.sample, scoreDisplay: "-1", nametag: false)
        GolferLeaderboardDisplay(golfer: Golfer.obscured, scoreDisplay: "-1", nametag: false)
    }.frame(height: 100)
        .background(Color.gray)
    
}
