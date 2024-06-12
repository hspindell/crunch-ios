//
//  CrunchButtonStyle.swift
//  Crunch
//
//  Created by Henry Spindell on 5/23/24.
//

import SwiftUI

struct CrunchButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
//            .solidShadow(backgroundColor: configuration.isPressed ? .buttonBackgroundPressed : .buttonBackground)
            .frame(height: 50)
    }
}
