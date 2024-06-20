//
//  PublicPoolListItem.swift
//  Crunch
//
//  Created by Henry Spindell on 6/17/24.
//

import SwiftUI

struct PublicPoolListItem: View {
    var pool: Pool
    var cardColor: Color
    
    var body: some View {
        Text("")
//        HStack {
//            VStack(alignment: .leading) {
//                Text(pool.title)
//                    .font(.system(size: 14, weight: .semibold))
//                Text(pool.event?.title ?? "")
//            }
//            Spacer()
//            VStack(alignment: .trailing) {
//                Text(pool.pool_type)
//                Text("Starts \(pool.event?.starts_at.formatted(.dateTime.month().day()) ?? "")")
//            }
//        }
//        .font(.system(size: 12))
//        .contentShape(Rectangle())
//        .padding(10)
//        .background(cardColor)
//        .clipShape(RoundedRectangle(cornerRadius: 10))
//        .overlay {
//            RoundedRectangle(cornerRadius: 10)
//                .fill(Color.clear)
//                .stroke(Color.black, lineWidth: 2)
//        }
//        .padding(2)
    }
}

#Preview {
    ZStack {
        StripeBG()
        PublicPoolListItem(pool: Pool.sample, cardColor: .crunchOrange)
    }
}
