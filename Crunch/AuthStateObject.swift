//
//  AuthStateObject.swift
//  Crunch
//
//  Created by Henry Spindell on 5/24/24.
//

import Foundation
import Supabase

class AuthStateObject: ObservableObject {
    @Published var authenticatedUser: User?
    @Published var authenticatedProfile: Profile?
    @Published var error: Error?
    
    func resumeSessionIfPossible() async {
        do {
            let session = try await supabase.auth.session
            await fetchProfile(from: session.user)
        } catch {
            print("resumeSessionIfPossible: \(error.localizedDescription)")
        }
    }
    
    func signUp(email: String, username: String, password: String) async {
        await MainActor.run { self.error = nil }
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
                self.authenticatedUser = authResponse.user
                self.authenticatedProfile = result
            }
        } catch {
            print("signUp: \(error.localizedDescription)")
            await MainActor.run {
                self.error = "Account creation failed with error: \(error.localizedDescription)".err
            }
        }
    }
    
    func signIn(email: String, password: String) async {
        await MainActor.run { self.error = nil }
        do {
            let session = try await supabase.auth.signIn(email: email, password: password)
            await fetchProfile(from: session.user)
        } catch {
            print("signIn: \(error.localizedDescription)")
            await MainActor.run {
                self.error = "Sign in failed with error: \(error.localizedDescription)".err
            }
        }
    }
    
    func signOut() async {
        do {
            try await supabase.auth.signOut()
            
            await MainActor.run {
                authenticatedProfile = nil
                authenticatedUser = nil
            }
        } catch {
            print("signOut: \(error.localizedDescription)")
        }
    }
    
    private func fetchProfile(from user: User) async {
        do {
            let result: Profile = try await supabase
              .from("profiles")
              .select()
              .eq("id", value: user.id)
              .single()
              .execute()
              .value
            await MainActor.run {
                authenticatedUser = user
                authenticatedProfile = result
            }
        } catch {
            print("fetchProfile: \(error.localizedDescription)")
        }
    }
}
