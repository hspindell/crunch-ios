//
//  SignInForm.swift
//  Crunch
//
//  Created by Henry Spindell on 5/24/24.
//

import SwiftUI

struct SignInForm: View {
    @EnvironmentObject var authObject: AuthStateObject
    @Binding var signInMode: Bool
    @State var email = ""
    @State var password = ""
    @State var inProgress = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            TextField("Enter email", text: $email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .textFieldStyle(CrunchFieldStyle())
                .labeled("Email", font: .system(size: 12, weight: .semibold), color: .white)
            SecureField("Enter password", text: $password)
                .textFieldStyle(CrunchFieldStyle())
                .labeled("Password", font: .system(size: 12, weight: .semibold), color: .white)
            Button("Sign in") {
                Task {
                    inProgress = true
                    await authObject.signIn(email: email, password: password)
                    inProgress = false
                }
            }
            .buttonStyle(CrunchButtonStyle())
            .disabled(email.isEmpty || password.isEmpty)
            HStack {
                Spacer()
                Text("Need to create an account?")
                Text("Sign up")
                    .fontWeight(.semibold)
                    .underline()
                Spacer()
            }
            .font(.callout)
            .onTapGesture { withAnimation { signInMode = false } }
        }.disabled(inProgress)
    }
}

#Preview {
    SignInForm(signInMode: .constant(false))
}
