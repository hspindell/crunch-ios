//
//  CreatePoolFlow.swift
//  Crunch
//
//  Created by Henry Spindell on 6/12/24.
//

import SwiftUI

final class CreatePoolManager: ObservableObject {
    enum Step {
        case circle, event, details
    }
    @Published var navigatingForward = true
    @Published var step = Step.circle
    var firstStep = Step.circle
    
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
    
    init(circle: CrCircle? = nil) {
        self.circle = circle
        self.firstStep = circle.isNil ? .circle : .event
        self.step = self.firstStep
    }

}

struct CreatePoolFlow: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var manager: CreatePoolManager
    
    private var step: CreatePoolManager.Step { manager.step }
    
    init(circle: CrCircle? = nil) {
        self._manager = StateObject(wrappedValue: CreatePoolManager(circle: circle))
    }
    
    var body: some View {
        VStack(spacing: 20) {
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
    @EnvironmentObject var manager: CreatePoolManager
    var title: String
    var subtitle: String?
    var hPadding: CGFloat = 15
    
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading) {
            Group {
                HStack {
                    if manager.step != manager.firstStep {
                        BackButton {
                            manager.goBack()
                        }
                        Spacer()
                    }
                    Text(title)
                        .font(.system(size: 20, weight: .semibold))
                    Spacer()
                    CloseButton()
                }

                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 14))
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
