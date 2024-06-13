//
//  CircleCard.swift
//  Crunch
//
//  Created by Henry Spindell on 6/12/24.
//

import SwiftUI

struct CircleCard: View {
    var circle: CrCircle?
    var selected = false
    private let height: CGFloat = 80
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(circle?.title ?? "New circle")
                    .font(.system(size: 14, weight: selected ? .bold : .regular))
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
        .background(selected ? Color.white : Color.backgroundCream)
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
    VStack {
        CircleCard(circle: CrCircle(id: .init(), created_at: Date(), title: "Circle XYZ", owner_id: .init()))
        CircleCard(circle: CrCircle(id: .init(), created_at: Date(), title: "Circle XYZ", owner_id: .init()), selected: true)
    }.frame(width: 300)
}
