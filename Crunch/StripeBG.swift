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

struct StripeBGDark: View {
    var reverse = false
    var body: some View {
        Stripes(config: StripesConfig(background: Color.black,
                                      foreground: Color.gray.opacity(0.4), degrees: reverse ? 45 : -45, barWidth: 20, barSpacing: 20))
        .edgesIgnoringSafeArea(.all)
    }
}

struct StripeBGThemeBlue: View {
    var reverse = false
    var body: some View {
        Stripes(config: StripesConfig(background: .themeBlue,
                                      foreground: Color.gray.opacity(0.4), degrees: reverse ? 45 : -45, barWidth: 20, barSpacing: 20))
        .edgesIgnoringSafeArea(.all)
    }
}

struct StripeBGThemeGreen: View {
    var reverse = false
    var body: some View {
        Stripes(config: StripesConfig(background: .themeGreen,
                                      foreground: Color.white.opacity(0.15), degrees: reverse ? 45 : -45, barWidth: 20, barSpacing: 20))
        .edgesIgnoringSafeArea(.all)
    }
}

struct StripeBGError: View {
    var reverse = false
    var body: some View {
        Stripes(config: StripesConfig(background: Color(hex: 0xfaa49d),
                                      foreground: Color.white.opacity(0.3), degrees: reverse ? 45 : -45, barWidth: 20, barSpacing: 20))
        .edgesIgnoringSafeArea(.all)
    }
}



#Preview {
    VStack {
        StripeBG()
        StripeBGDark()
        StripeBGThemeBlue()
        StripeBGThemeGreen()
        StripeBGError()
    }
}
