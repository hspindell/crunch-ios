//
//  Splash.swift
//  Crunch
//
//  Created by Henry Spindell on 6/28/24.
//

import SwiftUI

struct Splash: View {
    var body: some View {
        ZStack {
            Color.themeBlue
                .ignoresSafeArea()
            Image("fangs_only")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(h: 30)
        }
    }
}

#Preview {
    Splash()
}
