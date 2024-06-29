//
//  LandingPage.swift
//  Crunch
//
//  Created by Henry Spindell on 5/23/24.
//

import SwiftUI
import Supabase
import FirebaseMessaging

struct LandingPage: View {
    @StateObject var authStateObject = AuthStateObject()
    @State var checkedSession = false
    @State var signInMode = false
    @State var pendingDeepLinkURL: URL?
    
    @State var appObject: AppObject?
    
    #if targetEnvironment(simulator)
    @State var envToggle = Env.current == .local
    #endif
    
    let fcmTokenPublisher = NotificationCenter.default
                .publisher(for: NSNotification.Name("FCMToken"))
    
    var body: some View {
        Group {
            if checkedSession {
                VStack(spacing: 0) {
                    Image("full_logo_no_bg")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    
                    #if targetEnvironment(simulator)
                    Toggle("Local Dev", isOn: $envToggle)
                        .foregroundStyle(Color.white)
                        .font(.system(size: 16, weight: .semibold))
                        .frame(width: 140)
                        .onChange(of: envToggle) { oldValue, newValue in
                            Env.current = newValue ? .local : .dev
                            supabase = initSupabase()
                        }
                    #endif
                    
                    Spacer()

                    VStack(spacing: 20) {
                        if let error = authStateObject.error {
                            ErrorBar(text: error.localizedDescription)
                            .padding(h: 30)
                        }

                        if signInMode {
                            SignInForm(signInMode: $signInMode)
                            .padding(.leading, 30)
                            .padding(.trailing, 30)
                            .transition(.slide)
                        } else {
                            SignUpForm(signInMode: $signInMode)
                            .padding(.leading, 30)
                            .padding(.trailing, 30)
                            .transition(.slide)
                        }
                    }
                    .foregroundStyle(Color.white)
                }
                .background(StripeBGThemeBlue())
            } else {
                Splash()
            }
        }
        .task {
            await authStateObject.resumeSessionIfPossible()
            checkedSession = true
        }
        .onChange(of: signInMode, { oldValue, newValue in
            authStateObject.error = nil
        })
        .onChange(of: authStateObject.authenticatedProfile) { oldValue, newValue in
            if let newValue {
                appObject = AppObject(userProfile: newValue, pendingDeepLinkURL: pendingDeepLinkURL)
            } else {
                appObject = nil
                signInMode = true
            }
        }
        .fullScreenCover(item: $appObject) { appObject in
            UserHome()
                .environmentObject(appObject)
        }
        .onOpenURL { incomingURL in
            print("App was opened via URL: \(incomingURL)")
            if let appObject {
                appObject.handleIncomingURL(incomingURL)
                pendingDeepLinkURL = nil
            } else {
                pendingDeepLinkURL = incomingURL
            }
        }
        .onReceive(fcmTokenPublisher) { message in
            guard let token = message.userInfo?["token"] as? String else { return }
            Task {
                await authStateObject.updateFCMToken(token)
            }
        }
        .environmentObject(authStateObject)
    }
}

#Preview {
    LandingPage()
}
