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
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Create Circle")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.white)
                Spacer()
                CloseButton()
            }
            .padding(h: 15, v: 8)
            .background(StripeBGDark())
            
            Text("Circles allow you to invite your friends and automatically include and notify them for all future pools.")
                .font(.system(size: 14))
                .messageBox()
                .padding(h: 15)

            TextField("Circle name", text: $title)
                .textFieldStyle(CrunchFieldStyle())
                .labeled("Name")
                .padding(h: 15)
            Button("Save") {
                Task {
                    do {
                        let newCircle = CircleCreate(title: title)
                        let result: CrCircle = try await supabase
                            .from("circles")
                            .insert(newCircle)
                            .select()
                            .single()
                            .execute()
                            .value
                        appObject.deepLinkCircleId = result.id.uuidString
                        dismiss()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
            .buttonStyle(CrunchButtonStyle())
            .disabled(title.isEmpty)
            .padding(h: 15)
            Spacer()
        }
        
        .background(StripeBG())
        .onAppear {
            if title.isEmpty {
                title = "\(appObject.userProfile.username)'s Circle"
            }
        }
    }
}

#Preview {
    CreateCirclePage()
        .environmentObject(AppObject.sample)
}
