//
//  GolferListItem.swift
//  Crunch
//
//  Created by Henry Spindell on 6/17/24.
//

import SwiftUI

struct GolferListItem: View {
    var golfer: Golfer
    var selected: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            Text(selected ? "\(Image(systemName: "checkmark"))" : "—")
                .frame(width: 40, height: 40)
                .leadingHighlight(selected ? Color.crunchYellow : Color.white)
                
            Text("\(golfer.first_name) \(golfer.last_name)")
                .foregroundStyle(selected ? Color.crunchYellow : Color.white)
            Spacer()
            if let flagCode = golfer.flagCode {
                Image(flagCode)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 14)
            }
        }
        .padding(trailing: 15)
        .font(.system(size: 14, weight: .semibold))
        .contentShape(Rectangle())
        .background(Color.black)
    }
}

#Preview {
    VStack(spacing: 0) {
        GolferListItem(golfer: Golfer.sample, selected: false)
        GolferListItem(golfer: Golfer.sample, selected: true)
    }.frame(width: 300)
}
