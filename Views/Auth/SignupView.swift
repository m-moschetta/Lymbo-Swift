//
//  SignupView.swift
//  Lymbo
//
//  Created on 2025
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

struct SignupView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var authService = AuthService()
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var displayName = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Create Account")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.foreground)
                        
                        Text("Join Lymbo and connect with creatives")
                            .font(.system(size: 16))
                            .foregroundColor(.mutedForeground)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Signup Form
                    VStack(spacing: 20) {
                        // Display Name Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Display Name")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.foreground)
                            
                            TextField("Enter your name", text: $displayName)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
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
                        
                        // Confirm Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm Password")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.foreground)
                            
                            SecureField("Confirm your password", text: $confirmPassword)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Error Message
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                                .padding(.horizontal)
                        }
                        
                        // Sign Up Button
                        Button(action: handleSignup) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Create Account")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(isLoading || !isFormValid ? Color.gray : Color.primaryColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(isLoading || !isFormValid)
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
                }
                .padding(.bottom, 40)
            }
            .background(Color.backgroundColor)
            .navigationTitle("Sign Up")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !email.isEmpty &&
        !password.isEmpty &&
        !displayName.isEmpty &&
        password == confirmPassword &&
        password.count >= 6
    }
    
    private func handleSignup() {
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await authService.signUp(email: email, password: password, displayName: displayName)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
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
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
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
                    self.dismiss()
                } catch {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    SignupView()
}

