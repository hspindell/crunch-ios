//
//  ErrorBar.swift
//  Crunch
//
//  Created by Henry Spindell on 6/25/24.
//

import SwiftUI

struct ErrorBar: View {
    var text: String
    var body: some View {
        HStack {
            Text(text)
                .font(.system(size: 14, weight: .semibold))
                .fixedSize(horizontal: false, vertical: true)
                .foregroundStyle(Color.black)
            Spacer()
        }
        .padding(15)
        .background(StripeBGError())
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    ErrorBar(text: "An error is happening here An error is happening here An error is happening here An error is happening here")
}
