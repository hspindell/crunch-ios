//
//  ShadowedText.swift
//  Crunch
//
//  Created by Henry Spindell on 5/23/24.
//

import SwiftUI

struct ShadowedText: View {
    var text: String
    var fontSize: CGFloat
    
    init(_ text: String, fontSize: CGFloat = 60) {
        self.text = text
        self.fontSize = fontSize
    }
    
    var body: some View {
        ZStack {
            Text(text)
                .textCase(.uppercase)
                .font(.system(size: fontSize))
                .fontWeight(.bold)
                .offset(x: 2, y: 2)
            Text(text)
                .foregroundStyle(Color.white)
                .textCase(.uppercase)
                .font(.system(size: fontSize))
                .fontWeight(.bold)
                .offset(x: 1, y: 1)
            Text(text)
                .foregroundStyle(Color.buttonBackground)
                .textCase(.uppercase)
                .font(.system(size: fontSize))
                .fontWeight(.bold)
        }
    }
}

#Preview {
    ShadowedText("Crunch")
}
