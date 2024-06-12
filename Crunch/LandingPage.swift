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
            Image("inflatable_crunch")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .background(Color.black)
            
            Divider()
                .frame(height: 1)
                .background(Color(red: 59/255, green: 80/255, blue: 56/255))
            
            Spacer()

            VStack(spacing: 20) {
                ShadowedText("Crunch")
                Spacer()

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
            .padding(.bottom, 30)
        }
        .ignoresSafeArea(.all)
        .background(StripeBG())
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
