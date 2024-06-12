//
//  StripeBG.swift
//  Crunch
//
//  Created by Henry Spindell on 6/12/24.
//

import SwiftUI

struct StripeBG: View {
    var body: some View {
        Stripes(config: StripesConfig(background: Color.backgroundCream,
                                      foreground: Color.gray.opacity(0.08), degrees: -45, barWidth: 20, barSpacing: 20))
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    StripeBG()
}
