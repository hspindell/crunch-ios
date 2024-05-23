//
//  CreateCirclePage.swift
//  Crunch
//
//  Created by Henry Spindell on 5/22/24.
//

import SwiftUI

struct CreateCirclePage: View {
    @EnvironmentObject var appObject: AppObject
    @Environment(\.dismiss) var dismiss
    @State var title = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button("Back") {
                    dismiss()
                }
                Spacer()
            }
            Text("Create Circle")
                .font(.title)
            Spacer()
            TextField("Circle name", text: $title)
                .textFieldStyle(.roundedBorder)
            Spacer()
            Button("Save") {
                Task {
                    do {
                        let newCircle = CircleCreate(title: title)
                        try await supabase
                            .from("circles")
                            .insert(newCircle)
                            .execute()
                        dismiss()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }.disabled(title.isEmpty)
        }
        .padding(30)
        .onAppear {
            if title.isEmpty {
                title = "\(appObject.userProfile.username)'s Circle"
            }
        }
    }
}

#Preview {
    CreateCirclePage()
}
