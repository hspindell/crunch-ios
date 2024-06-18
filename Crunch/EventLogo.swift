//
//  EventLogo.swift
//  Crunch
//
//  Created by Henry Spindell on 6/17/24.
//

import SwiftUI

struct EventLogo: View {
    var url: URL?
    var body: some View {
        AsyncImage(url: url) { result in
            result.image?
                .resizable()
                .scaledToFit()
                .frame(height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .frame(height: 60)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black, lineWidth: 2)
        )
    }
}

#Preview {
    EventLogo()
}
