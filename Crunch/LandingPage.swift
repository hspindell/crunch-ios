//
//  LandingPage.swift
//  Crunch
//
//  Created by Henry Spindell on 5/23/24.
//

import SwiftUI
import Supabase

let devMode = false

struct LandingPage: View {
    @StateObject var authStateObject = AuthStateObject()
    @State var signInMode = false
    @State var pendingDeepLinkURL: URL?
    
    @State var appObject: AppObject?
    
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Image("full_logo_no_bg")
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            Spacer()

            VStack(spacing: 20) {
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
            .padding(.bottom, 30)
        }
        .ignoresSafeArea(.all)
        .background(StripeBGTheme())
        .task {
            // TODO splash screen while checking login status
            await authStateObject.resumeSessionIfPossible()
        }
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
//        .onOpenURL { incomingURL in
//            print("App was opened via URL: \(incomingURL)")
//            if let appObject {
//                appObject.handleIncomingURL(incomingURL)
//                pendingDeepLinkURL = nil
//            } else {
//                pendingDeepLinkURL = incomingURL
//            }
//        }
        .environmentObject(authStateObject)
    }
}

#Preview {
    LandingPage()
}
