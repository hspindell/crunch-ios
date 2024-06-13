//
//  PoolCard.swift
//  Crunch
//
//  Created by Henry Spindell on 5/27/24.
//

import SwiftUI

struct PoolCard: View {
    var title: String?
    var entry: MyEntryOverview?
    var backgroundColor = Color.crunchGreen
    
    private let cornerRadius: CGFloat = 15
    
    var body: some View {
        ShadowBox(size: CGSize(width: 120, height: 160), backgroundColor: backgroundColor, cornerRadius: 15, shadowOffset: (3, 5)) {
            VStack(spacing: 30) {
                ZStack {
                    Circle()
                        .stroke(.black, lineWidth: 5)
                        .fill(Color.backgroundCream)
                        .frame(width: 50, height: 50)
                    
                    if let entry {
                        AsyncImage(url: entry.pool.event?.logoURL) { result in
                            result.image?
                                .resizable()
                                .scaledToFill()
                                .clipShape(Circle())
                        }
                        .frame(width: 50, height: 50)
                    } else {
                        Text("+")
                            .font(.title)
                    }
                }
                .solidShadow(size: CGSize(width: 55, height: 55), cornerRadius: 27.5, offset: (1, 2))

                Text(title ?? entry?.title ?? "")
                    .font(.system(size: 14, weight: .medium))
            }
        }
    }
}

#Preview {
    ZStack {
        Color.blue
        PoolCard()
    }
}
