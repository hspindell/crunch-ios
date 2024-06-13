//
//  CreatePoolDetails.swift
//  Crunch
//
//  Created by Henry Spindell on 6/13/24.
//

import SwiftUI

struct CreatePoolDetails: View {
    @State var poolTitle = "Default Title Here"
    @State var poolDetails = ""
    @State var poolIsPublic = false
    var body: some View {
        CreatePoolStepBody(title: "Complete your pool details") {
            VStack(spacing: 20) {
                TextField("", text: $poolTitle)
                    .textFieldStyle(CrunchFieldStyle())
                    .labeled("Title")
                    .padding(top: 15)
                    
                // TODO TextEditor/multiline style
                TextField("Add any relevant information such as buy-in and payout structure", text: $poolDetails)
                    .textFieldStyle(CrunchFieldStyle())
                    .labeled("Details")
                
                Toggle("Public", isOn: $poolIsPublic)
                    .tint(.crunchCyan)
                    .padding(10)
                    .background(Color.backgroundCream)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.24), lineWidth: 2)
                    )
                if poolIsPublic {
                    Text("Pool will be listed publicly and anyone will be allowed to join")
                        .font(.caption)
                } else {
                    Text("Pool will only be findable by those with the link")
                        .font(.caption)
                }
                
                Spacer()
                
                Button("Create") {
                // TODO get other info from flow + submit
//                    Task {
//                        do {
//                            let newPool = PoolCreate(circle_id: circle?.id, event_id: event.id, title: poolName, details: details, pool_type: .golfPickSix, is_public: isPublic)
//                            try await supabase
//                                .from("pools")
//                                .insert(newPool)
//                                .execute()
//                            dismiss()
//                        } catch {
//                            print(error.localizedDescription)
//                        }
//                    }
                }
                .buttonStyle(CrunchButtonStyle())
                .disabled(poolTitle.isEmpty)
            }
        }
    }
}

struct CrunchFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(10)
            .background(Color.backgroundCream)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.24), lineWidth: 2)
            )
    }
}

#Preview {
    CreatePoolDetails()
}
