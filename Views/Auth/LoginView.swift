//
//  LoginView.swift
//  Lymbo
//
//  Created on 2025
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

struct LoginView: View {
    @StateObject private var authService = AuthService()
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showSignup = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                // Logo/Header
                VStack(spacing: 16) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.primaryColor)
                    
                    Text("Lymbo")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.foreground)
                    
                    Text("Connect with creative professionals")
                        .font(.system(size: 16))
                        .foregroundColor(.mutedForeground)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 60)
                
                // Login Form
                VStack(spacing: 20) {
                    // Email Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.foreground)
                        
                        TextField("Enter your email", text: $email)
                            .textFieldStyle(CustomTextFieldStyle())
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                    }
                    
                    // Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.foreground)
                        
                        SecureField("Enter your password", text: $password)
                            .textFieldStyle(CustomTextFieldStyle())
                    }
                    
                    // Error Message
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                    
                    // Login Button
                    Button(action: handleLogin) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Sign In")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(isLoading ? Color.gray : Color.primaryColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(isLoading || email.isEmpty || password.isEmpty)
                    
                    // Forgot Password
                    Button(action: handleForgotPassword) {
                        Text("Forgot Password?")
                            .font(.system(size: 14))
                            .foregroundColor(.primaryColor)
                    }
                }
                .padding(.horizontal, 24)
                
                // Divider
                HStack {
                    Rectangle()
                        .fill(Color.border)
                        .frame(height: 1)
                    Text("OR")
                        .font(.system(size: 14))
                        .foregroundColor(.mutedForeground)
                        .padding(.horizontal, 16)
                    Rectangle()
                        .fill(Color.border)
                        .frame(height: 1)
                }
                .padding(.horizontal, 24)
                
                // Google Sign In
                Button(action: handleGoogleSignIn) {
                    HStack {
                        Image(systemName: "globe")
                        Text("Continue with Google")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.card)
                    .foregroundColor(.foreground)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.border, lineWidth: 1)
                    )
                }
                .padding(.horizontal, 24)
                .disabled(isLoading)
                
                Spacer()
                
                // Sign Up Link
                HStack {
                    Text("Don't have an account?")
                        .font(.system(size: 14))
                        .foregroundColor(.mutedForeground)
                    
                    Button(action: { showSignup = true }) {
                        Text("Sign Up")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primaryColor)
                    }
                }
                .padding(.bottom, 40)
            }
            .background(Color.backgroundColor)
            .navigationBarHidden(true)
            .sheet(isPresented: $showSignup) {
                SignupView()
            }
        }
    }
    
    private func handleLogin() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await authService.signIn(email: email, password: password)
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    private func handleForgotPassword() {
        guard !email.isEmpty else {
            errorMessage = "Please enter your email first"
            return
        }
        
        Task {
            do {
                try await authService.resetPassword(email: email)
                errorMessage = "Password reset email sent!"
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func handleGoogleSignIn() {
        isLoading = true
        errorMessage = nil
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            isLoading = false
            errorMessage = "Unable to get root view controller"
            return
        }
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            isLoading = false
            errorMessage = "Google Sign-In configuration error"
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [self] result, error in
            self.isLoading = false
            
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                self.errorMessage = "Failed to get Google credentials"
                return
            }
            
            let accessToken = user.accessToken.tokenString
            
            Task { @MainActor in
                do {
                    try await self.authService.signInWithGoogle(idToken: idToken, accessToken: accessToken)
                } catch {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .foregroundColor(.foreground)
            .padding(16)
            .background(Color.card)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.border, lineWidth: 1)
            )
    }
}

#Preview {
    LoginView()
}

