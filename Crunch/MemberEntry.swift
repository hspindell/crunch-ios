//
//  MemberEntry.swift
//  Crunch
//
//  Created by Henry Spindell on 6/15/24.
//

import SwiftUI

struct MemberEntry: View {
    var entry: Entry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(entry.title.presence ?? "\(entry.profile?.username ?? "user")'s entry")
                    .font(.system(size: 14, weight: .semibold))
                Text(entry.profile?.username ?? "")
                    .font(.system(size: 12))
            }
            
            Spacer()
            Text(entry.complete ? "Complete" : "Incomplete")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(entry.complete ? Color.crunchGreen : Color.crunchOrange)
        }
        .contentShape(Rectangle())
        .padding(8)
        .highlighted(.black.opacity(0.5))
        .foregroundStyle(Color.white)
    }
}

#Preview {
    VStack {
        MemberEntry(entry: Entry.sample)
    }.frame(width: 300)
    
}
