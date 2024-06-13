//
//  CreatePoolFlow.swift
//  Crunch
//
//  Created by Henry Spindell on 6/12/24.
//

import SwiftUI

final class CreateCircleManager: ObservableObject {
    enum Step {
        case circle, event
    }
    @Published var navigatingForward = true
    @Published var step = Step.circle
    
    func slideTo(step: Step, forward: Bool = true) {
        navigatingForward = forward
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.step = step
        }
    }
    

}

struct CreatePoolFlow: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var manager = CreateCircleManager()
    
    private var step: CreateCircleManager.Step { manager.step }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                if manager.step != .circle {
                    Button("< Back") {
                        manager.slideTo(step: .circle, forward: false)
                    }
                }
                Spacer()
                Button("Close") {
                    dismiss()
                }
            }.padding(h: 15)

            Group {
                if step == .circle {
                    CreatePoolChooseCircle()
                } else if step == .event {
                    CreatePoolChooseEvent()
                }
            }
            .transition(AnyTransition.asymmetric(
                insertion: .move(edge: manager.navigatingForward ? .trailing : .leading),
                removal: .move(edge: manager.navigatingForward ? .leading : .trailing)
            ))
            .animation(.easeInOut, value: manager.step)
        }
        .padding(v: 15)
        .background(StripeBG())
        .environmentObject(manager)
    }
}

struct CreatePoolStepBody<Content: View>: View {
    var title: String
    var subtitle: String?
    
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading) {
            Group {
                Text(title)
                    .font(.title)
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                }
            }
            content
                .padding(top: 30)

        }.padding(h: 15)
    }
}

#Preview {
    CreatePoolFlow()
        .environmentObject(AppObject.sample)
}
