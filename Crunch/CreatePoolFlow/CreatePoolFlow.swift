//
//  CreatePoolFlow.swift
//  Crunch
//
//  Created by Henry Spindell on 6/12/24.
//

import SwiftUI

final class CreateCircleManager: ObservableObject {
    enum Step {
        case circle, event, details
    }
    @Published var navigatingForward = true
    @Published var step = Step.circle
    
    var circle: CrCircle?
    var event: Event?
    
    
    func slideTo(step: Step, forward: Bool = true) {
        navigatingForward = forward
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.step = step
        }
    }
    
    func goBack() {
        slideTo(step: step == .event ? .circle : .event, forward: false)
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
                        manager.goBack()
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
                } else if step == .details {
                    CreatePoolDetails()
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
    var hPadding: CGFloat = 15
    
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
            VStack(spacing: 0) {
                Divider()
                content
            }
        }.padding(h: hPadding)
    }
}

#Preview {
    CreatePoolFlow()
        .environmentObject(AppObject.sample)
}
