//
//  Modifiers.swift
//  Crunch
//
//  Created by Henry Spindell on 6/14/24.
//

import SwiftUI

//struct HighlightedModifier : ViewModifier {
//    var color = Color.crunchYellow
//    func body(content: Content) -> some View {
//        content.background(color.mask(Highlighter()))
//    }
//}

extension View {
    func highlighted(_ color: Color = .crunchYellow) -> some View {
        self.background(color.mask(Highlighter()))
    }
    
    func leadingHighlight(_ color: Color = .crunchYellow) -> some View {
        return self.background(color.mask(LeadingHighlighter()))
    }
    
    func trailingHighlight(_ color: Color = .crunchYellow) -> some View {
        return self.background(color.mask(TrailingHighlighter()))
    }
}
