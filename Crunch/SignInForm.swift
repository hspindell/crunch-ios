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
            TextField("", text: .constant("")).hidden() // to keep height the same
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
            SecureField("Password", text: $password)
            Button("Sign in") {
                Task {
                    inProgress = true
                    await authObject.signIn(email: email, password: password)
                    inProgress = false
                }
            }.buttonStyle(CrunchButtonStyle())
            HStack {
                Spacer()
                Text("Need to create an account?")
                    .foregroundStyle(Color.lightText)
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
