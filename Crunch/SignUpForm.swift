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
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
            TextField("Username", text: $username)
                .textInputAutocapitalization(.never)
            SecureField("Password", text: $password)
            Button("Sign up") {
                Task {
                    inProgress = true
                    await authObject.signUp(email: email, username: username, password: password)
                    inProgress = false
                }
            }.buttonStyle(CrunchButtonStyle())
            HStack {
                Spacer()
                Text("Already have an account?")
                    .foregroundStyle(Color.lightText)
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
