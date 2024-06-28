//
//  LandingPage.swift
//  Crunch
//
//  Created by Henry Spindell on 5/23/24.
//

import SwiftUI
import Supabase

struct LandingPage: View {
    @StateObject var authStateObject = AuthStateObject()
    @State var signInMode = false
    @State var pendingDeepLinkURL: URL?
    
    @State var appObject: AppObject?
    
    #if DEBUG
    @State var devToggle = Env.isDev
    #endif
    
    var body: some View {
        VStack(spacing: 0) {
            Image("full_logo_no_bg")
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            #if DEBUG
            Toggle("Dev Mode", isOn: $devToggle)
                .foregroundStyle(Color.white)
                .font(.system(size: 16, weight: .semibold))
                .frame(width: 140)
                .onChange(of: devToggle) { oldValue, newValue in
                    Env.current = newValue ? .dev : .prod
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
        .task {
            // TODO splash screen while checking login status
            await authStateObject.resumeSessionIfPossible()
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
        .environmentObject(authStateObject)
    }
}

#Preview {
    LandingPage()
}
