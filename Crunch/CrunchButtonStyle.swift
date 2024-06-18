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
    var small = false
    var bgColor = Color.buttonBackground
    var textColor = Color.black
    
    func backgroundColor(config: Configuration) -> Color {
        if isEnabled == false {
            return .gray
        }
        return config.isPressed ? bgColor.tint(15) : bgColor
    }
    
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geo in
            ShadowBox(size: CGSize(width: geo.size.width, height: geo.size.height), backgroundColor: backgroundColor(config: configuration), cornerRadius: 10, shadowOffset: small ? (1, 3) : (3, 5)) {
                HStack {
                    configuration.label
                        .font(.system(size: small ? 14 : 18, weight: .semibold))
                        .foregroundStyle(textColor)
                    if flow {
                        Spacer()
                        Text(">>>") // TODO animated "turn signal" effect
                    }
                }.padding(h: 18)
            }
        }.frame(height: small ? 25 : 50)
    }
}

#Preview {
    VStack {
        Button("Small") {}
            .buttonStyle(CrunchButtonStyle(small: true))
            .frame(width: 100)
        Button("Submit") {}
            .buttonStyle(CrunchButtonStyle())
        Button("Continue") {}
            .buttonStyle(CrunchButtonStyle(flow: true))
    }

}
