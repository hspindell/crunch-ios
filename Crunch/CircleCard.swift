//
//  CircleCard.swift
//  Crunch
//
//  Created by Henry Spindell on 6/12/24.
//

import SwiftUI

struct CircleCard: View {
    var circle: CrCircle?
    private let height: CGFloat = 80
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(circle?.title ?? "New circle")
                    .font(.system(size: 14))
                Spacer()
                if circle.isNil {
                    Text("+")
                }
            }

            Text(circle?.owner?.username ?? "Invite friends to your pools automatically")
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
        .solidShadow(cornerRadius: 10, offset: (2, 3))
        .frame(height: height)
    }
}

#Preview {
    CircleCard(circle: CrCircle(id: .init(), created_at: Date(), title: "Circle XYZ", owner_id: .init()))
        .frame(width: 300)
}
