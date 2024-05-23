//
//  ContentView.swift
//  payup
//
//  Created by Henry Spindell on 4/11/24.
//

import SwiftUI
import SwiftData

import FirebaseAuth
import FirebaseFirestore

import Supabase

let supabase = SupabaseClient(supabaseURL: URL(string: "https://arsfsniyfuubvmnwxhvh.supabase.co")!, supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFyc2Zzbml5ZnV1YnZtbnd4aHZoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTM1NTg3MzQsImV4cCI6MjAyOTEzNDczNH0.XLSfAlrkG1PydgkUBswpV7cIQ0uFyDBDa-Hmltyh7UY")


class AppObject: ObservableObject {
    @Published var userProfile: Profile
    @Published var circles = [Circle]()
    @Published var deepLinkPoolId: String?
    @Published var deepLinkCircleId: String?
    
    init(userProfile: Profile) {
        self.userProfile = userProfile
    }
}

class DeepLink {
    enum Action: String {
        case joinCircle = "join-circle"
        case joinPool = "join-pool"
    }
    
    static func build(action: Action, params: [URLQueryItem] = []) -> String {
        let queryString = params.compactMap { item in
            guard let val = item.value else { return nil }
            return "\(item.name)=\(val)"
        }.joined(separator: "&")
        return "crunchapp://\(action.rawValue)?\(queryString)"
    }
}


struct ContentView: View {
    @State var authenticatedUser: Profile?
    @State var appObject: AppObject?
    
    @State var email = "henryspindell@gmail.com"
    @State var username = ""
    @State var password = "123456"
    @State var signup = false
    @State var pendingDeepLinkUrl: URL?
    

    
    /// Handles the incoming URL and performs validations before acknowledging.
    private func handleIncomingURL(_ url: URL) {
        // if not logged in, store for later
        if authenticatedUser.isNil {
            pendingDeepLinkUrl = url
            return
        }
            
        guard url.scheme == "crunchapp" else {
            return
        }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            print("Invalid deep link URL")
            return
        }

        guard let actionRaw = components.host, let action = DeepLink.Action(rawValue: actionRaw) else {
            print("Unknown deep link action")
            return
        }

        guard let id = components.queryItems?.first(where: { $0.name == "id" })?.value else {
            print("Deep link ID not found")
            return
        }
        
        // fetch specified pool or circle
        if action == .joinCircle {
            appObject?.deepLinkCircleId = id
        } else if action == .joinPool {
            appObject?.deepLinkPoolId = id
        }        
    }
    
    private func fetchUser(from id: UUID) async {
        do {
            let result: Profile = try await supabase
              .from("profiles")
              .select()
              .eq("id", value: id)
              .single()
              .execute()
              .value
            await MainActor.run {
                authenticatedUser = result
            }
        } catch {
            print("fetchUser: \(error.localizedDescription)")
        }
    }
    
    var body: some View {
        Group {
            if let appObject {
                Home(authenticatedUser: $authenticatedUser)
                    .environmentObject(appObject)
            } else {
                VStack {
                    Text("Crunch")
                        .font(.title)
                    Spacer()
                    Text("Sign Up")
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                    TextField("Username", text: $username)
                    SecureField("Password", text: $password)
                    Button("Sign Up") {
                        Task {
                            do {
                                let authResponse = try await supabase.auth.signUp(email: email, password: password)
                                let result: Profile = try await supabase
                                    .from("profiles")
                                    .update(["username": username])
                                    .eq("id", value: authResponse.user.id)
                                    .select()
                                    .single()
                                    .execute()
                                    .value
                                await MainActor.run {
                                    authenticatedUser = result
                                }
                            } catch {
                                print("Sign up: \(error.localizedDescription)")
                            }
                        }
                    }
                    
                    Spacer()
                    Text("Log in")
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                    SecureField("Password", text: $password)
                    Button("Log In") {
                        Task {
                            do {
                                let session = try await supabase.auth.signIn(email: email, password: password)
                                await fetchUser(from: session.user.id)
                            } catch {
                                print("Sign in: \(error.localizedDescription)")
                            }
                        }
                    }
                    Spacer()
                }
                .padding(30)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .task {
                    do {
                        // TODO splash screen while checking login status
                        let session = try await supabase.auth.session
                        await fetchUser(from: session.user.id)
                    } catch {
                        print("Resume session: \(error.localizedDescription)")
                    }
                }
            }
        }
        .onChange(of: authenticatedUser) { oldValue, newValue in
            if let newValue {
                appObject = AppObject(userProfile: newValue)
                if let pendingDeepLinkUrl {
                    handleIncomingURL(pendingDeepLinkUrl)
                }
            } else {
                // user signed out
                appObject = nil
            }
        }
        .onOpenURL { incomingURL in
            print("App was opened via URL: \(incomingURL)")
            handleIncomingURL(incomingURL)
        }
    }
}

#Preview {
    ContentView()
}
