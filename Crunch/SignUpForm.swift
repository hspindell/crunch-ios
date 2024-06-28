//
//  SignUpForm.swift
//  Crunch
//
//  Created by Henry Spindell on 5/24/24.
//

import SwiftUI

struct SignUpForm: View {
    @EnvironmentObject var authObject: AuthStateObject
    @Binding var signInMode: Bool
    @State var email = ""
    @State var username = ""
    @State var password = ""
    @State var inProgress = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            TextField("Enter email", text: $email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .textFieldStyle(CrunchFieldStyle())
                .labeled("Email", font: .system(size: 12, weight: .semibold), color: .white)
            TextField("Enter username", text: $username)
                .textInputAutocapitalization(.never)
                .textFieldStyle(CrunchFieldStyle())
                .labeled("Username", font: .system(size: 12, weight: .semibold), color: .white)
            SecureField("Enter password", text: $password)
                .textFieldStyle(CrunchFieldStyle())
                .labeled("Password", font: .system(size: 12, weight: .semibold), color: .white)
            Button("Sign up") {
                Task {
                    inProgress = true
                    await authObject.signUp(email: email, username: username, password: password)
                    inProgress = false
                }
            }
            .buttonStyle(CrunchButtonStyle())
            .disabled(email.isEmpty || username.isEmpty || password.isEmpty)
            HStack {
                Spacer()
                Text("Already have an account?")
                Text("Sign in")
                    .fontWeight(.semibold)
                    .underline()
                Spacer()
            }
            .font(.callout)
            .onTapGesture { withAnimation { signInMode = true } }
        }.disabled(inProgress)
    }
}

#Preview {
    SignUpForm(signInMode: .constant(false))
}
