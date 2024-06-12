//
//  MyPoolsCarousel.swift
//  Crunch
//
//  Created by Henry Spindell on 5/27/24.
//

import SwiftUI

struct MyPoolsCarousel: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                PoolCard()
                PoolCard(backgroundColor: .crunchCyan)
                PoolCard(backgroundColor: .crunchPurple)
                PoolCard(backgroundColor: .crunchGreen)
            }
            .padding(.leading, 30)
            .padding(.trailing, 30)
            .padding(.bottom, 5)
        }
    }
}

#Preview {
    MyPoolsCarousel()
}
