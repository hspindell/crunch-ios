//
//  ShadowBox.swift
//  Crunch
//
//  Created by Henry Spindell on 5/28/24.
//

import SwiftUI

struct ShadowBox<Content: View>: View {
    var size: CGSize
    var backgroundColor: Color
    var cornerRadius: CGFloat
    var shadowOffset: (CGFloat, CGFloat)
    var innerBorderColor = Color.white
    var innerBorderWidth: CGFloat = 2
    @ViewBuilder var content: Content
    
    var body: some View {
        content
            .frame(width: size.width, height: size.height)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(.white, lineWidth: innerBorderWidth)
            )
            .solidShadow(size: size, cornerRadius: cornerRadius, offset: shadowOffset)
    }
}

#Preview {
    ShadowBox(size: CGSize(width: 100, height: 50), backgroundColor: Color.orange, cornerRadius: 10, shadowOffset: (2, 2), innerBorderWidth: 2) {
        Text("Banana")
    }
}
