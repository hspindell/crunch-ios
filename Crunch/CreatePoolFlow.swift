//
//  CreatePoolFlow.swift
//  Crunch
//
//  Created by Henry Spindell on 6/12/24.
//

import SwiftUI

struct CreatePoolFlow: View {
    var body: some View {
        VStack {
            CreatePoolChooseCircle()
            
            
            Button("Continue") {
                
            }
            .buttonStyle(CrunchButtonStyle(flow: true))
            .padding(h: 30)
        }
        .padding(v: 30)
        .background(StripeBG())
    }
}



struct CreatePoolChooseCircle: View {
    @EnvironmentObject var appObject: AppObject
    
    private var circlesAsAdmin: [CrCircle] {
        appObject.circles.filter({ $0.owner_id == appObject.userProfile.id })
    }
    
    var body: some View {
        CreatePoolStepBody(title: "Is this pool part of a circle? (optional)", subtitle: "You may only choose a circle for which you are an admin.") {
            VStack {
                ForEach(circlesAsAdmin) { c in
                    CircleCard(circle: c)
                            .onTapGesture {
    //                            selectedCircle = circle
                            }
                }

                CircleCard()
                    .onTapGesture {
    //                        showCreateCircle = true
                    }
            }

        }
    }
}

struct CreatePoolStepBody<Content: View>: View {
    var title: String
    var subtitle: String
    
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title)
            Text(subtitle)
                .font(.subheadline)
            
            ScrollView {
                content
            }
            
            Spacer()
        }.padding(h: 30)
    }
}

#Preview {
    CreatePoolFlow()
        .environmentObject(AppObject(userProfile: Profile.sample))
}
