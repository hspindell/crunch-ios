//
//  CrunchButtonStyle.swift
//  Crunch
//
//  Created by Henry Spindell on 5/23/24.
//

import SwiftUI

struct CrunchButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    var flow = false
    
    func backgroundColor(config: Configuration) -> Color {
        if isEnabled == false {
            return .gray
        }
        return config.isPressed ? .buttonBackgroundPressed : .buttonBackground
    }
    
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geo in
            ShadowBox(size: CGSize(width: geo.size.width, height: geo.size.height), backgroundColor: backgroundColor(config: configuration), cornerRadius: 10, shadowOffset: (3, 5)) {
                HStack {
                    configuration.label
                        .fontWeight(.semibold)
                    if flow {
                        Spacer()
                        Text(">>>") // TODO animated "turn signal" effect
                    }
                }.padding(h: 18)
            }
        }.frame(height: 50)
    }
}

#Preview {
    VStack {
        Button("Submit") {}
            .buttonStyle(CrunchButtonStyle())
        Button("Continue") {}
            .buttonStyle(CrunchButtonStyle(flow: true))
    }

}
