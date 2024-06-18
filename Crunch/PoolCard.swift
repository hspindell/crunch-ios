//
//  PoolCard.swift
//  Crunch
//
//  Created by Henry Spindell on 5/27/24.
//

import SwiftUI

struct PoolCard: View {
    var title: String?
    var subtitle: String?
    var pool: Pool?
    var backgroundColor = Color.crunchGreen
    
    private let cornerRadius: CGFloat = 15
    
    var body: some View {
        ShadowBox(size: CGSize(width: 120, height: 160), backgroundColor: backgroundColor, cornerRadius: 15, shadowOffset: (3, 5)) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .stroke(.black, lineWidth: 5)
                        .fill(Color.backgroundCream)
                        .frame(width: 50, height: 50)
                    
                    if let pool {
                        AsyncImage(url: pool.event?.logoURL) { result in
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
                Spacer()

                VStack(spacing: 4) {
                    Text(title ?? pool?.title ?? "Pool")
                        .font(.system(size: 14, weight: .semibold))
                    Text(subtitle ?? pool?.pool_type ?? "")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(Color.gray.shade(50))
                }.padding(h: 8)
            }.padding(v:30)
        }
    }
}

#Preview {
    ZStack {
        Color.blue
        HStack {
            PoolCard()
            PoolCard(title: "Long Title Test", subtitle: "Second line")
        }
    }
}
