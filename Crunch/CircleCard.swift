//
//  CircleCard.swift
//  Crunch
//
//  Created by Henry Spindell on 6/12/24.
//

import SwiftUI

struct CircleCard: View {
    var circle: CrCircle
    private let height: CGFloat = 80
    
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(circle.title)
                        .font(.system(size: 14))
                    Spacer()
                }

                Text(circle.owner?.username ?? "Owner")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.gray)
            }
            .padding(h: 15)
            .frame(height: height)
            .background(Color.backgroundCream)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.black, lineWidth: 2)
            )
            .solidShadow(size: CGSize(width: geo.size.width, height: height), cornerRadius: 10, offset: (2, 3))
            
        }
    }
}

#Preview {
    CircleCard(circle: CrCircle(id: .init(), created_at: Date(), title: "Circle XYZ", owner_id: .init()))
        .frame(width: 300)
}
