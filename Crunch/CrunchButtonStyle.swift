//
//  CrunchButtonStyle.swift
//  Crunch
//
//  Created by Henry Spindell on 5/23/24.
//

import SwiftUI

struct CrunchButtonStyle: ButtonStyle {
    var flow = false
    
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geo in
            ShadowBox(size: CGSize(width: geo.size.width, height: geo.size.height), backgroundColor: configuration.isPressed ? .buttonBackgroundPressed : .buttonBackground, cornerRadius: 10, shadowOffset: (3, 5)) {
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
