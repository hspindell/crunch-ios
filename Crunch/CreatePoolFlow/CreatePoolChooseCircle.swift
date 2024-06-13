//
//  CreatePoolChooseCircle.swift
//  Crunch
//
//  Created by Henry Spindell on 6/12/24.
//

import SwiftUI

struct CreatePoolChooseCircle: View {
    @EnvironmentObject var appObject: AppObject
    @EnvironmentObject var manager: CreateCircleManager
    @State var selectedCircle: CrCircle?
    
    private var circlesAsAdmin: [CrCircle] {
        appObject.circles.filter({ $0.owner_id == appObject.userProfile.id })
    }
    
    var body: some View {
        CreatePoolStepBody(title: "Select a circle", subtitle: "All members of the chosen circle will automatically be invited to participate in this pool. You may only choose a circle for which you are an admin.") {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 10) {
                    ForEach(circlesAsAdmin) { c in
                        CircleCard(circle: c, selected: selectedCircle == c)
                            .padding(h: 5)
                            .onTapGesture {
                                if selectedCircle == c {
                                    selectedCircle = nil
                                } else {
                                    selectedCircle = c
                                }
                            }
                    }

                    CircleCard()
                        .padding(h: 5)
                        .onTapGesture {
    //                        showCreateCircle = true
                    }
                }.padding(v: 15)
            }
            
            Spacer()
            
            Button(selectedCircle.hasValue ? "Continue" : "Skip") {
                manager.slideTo(step: .event)
            }
            .buttonStyle(CrunchButtonStyle(flow: true))
        }
    }
}

#Preview {
    CreatePoolChooseCircle()
        .environmentObject(AppObject.sample)
        .environmentObject(CreateCircleManager())
}
