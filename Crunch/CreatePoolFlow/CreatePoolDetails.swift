//
//  CreatePoolDetails.swift
//  Crunch
//
//  Created by Henry Spindell on 6/13/24.
//

import SwiftUI

struct CreatePoolDetails: View {
    @EnvironmentObject var appObject: AppObject
    @EnvironmentObject var manager: CreateCircleManager
    @State var poolTitle = ""
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
                    guard let eventId = manager.event?.id else {
                        return
                    }
                    Task {
                        do {
                            let poolData = PoolCreate(circle_id: manager.circle?.id, event_id: eventId, title: poolTitle, details: poolDetails, pool_type: .golfPickSix, is_public: poolIsPublic)
                            let pool: Pool = try await supabase
                                .from("pools")
                                .insert(poolData)
                                .select()
                                .single()
                                .execute()
                                .value
                            appObject.deepLinkPoolId = pool.id.uuidString
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
                .buttonStyle(CrunchButtonStyle())
                .disabled(poolTitle.isEmpty)
            }
        }.onAppear {
            poolTitle = manager.event?.title ?? "My Pool"
        }
    }
}

struct CrunchFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(10)
            .background(Color.backgroundCream)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.24), lineWidth: 2)
            )
    }
}

// Extension to make it easier to apply the custom style
extension View {
    func crunchEditorStyle() -> some View {
        self.modifier(CrunchFieldModifier())
    }
}


struct CrunchFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .crunchEditorStyle()
    }
}

#Preview {
    CreatePoolDetails()
}
