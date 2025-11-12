//
//  SplashView.swift
//  Lymbo
//
//  Created on 2025
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

struct SplashView: View {
    @EnvironmentObject var authService: AuthService
    @State private var showSignIn = false
    @State private var showCreateAccount = false
    @State private var showLoginForm = false
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            Color.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // App Name and Claim
                VStack(spacing: 16) {
                    Text("Lymbo")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.foreground)
                    
                    Text("Flip The Script")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.mutedForeground)
                }
                
                Spacer()
                
                // Login Form (se mostrato)
                if showLoginForm {
                    VStack(spacing: 20) {
                        // Email Field
                        TextField("Email", text: $email)
                            .textFieldStyle(CustomTextFieldStyle())
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .foregroundColor(.foreground)
                        
                        // Password Field
                        SecureField("Password", text: $password)
                            .textFieldStyle(CustomTextFieldStyle())
                            .foregroundColor(.foreground)
                        
                        // Error Message
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Login Button
                        Button(action: handleEmailLogin) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Sign In")
                                        .font(.system(size: 18, weight: .semibold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(isLoading || email.isEmpty || password.isEmpty ? Color.gray : Color.primaryColor)
                            .cornerRadius(12)
                        }
                        .disabled(isLoading || email.isEmpty || password.isEmpty)
                        
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
                        
                        // Google Sign In
                        Button(action: handleGoogleSignIn) {
                            HStack {
                                Image(systemName: "globe")
                                    .font(.system(size: 18))
                                Text("Continue with Google")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(.foreground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.card)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.border, lineWidth: 1)
                            )
                        }
                        .disabled(isLoading)
                        
                        // Apple Sign In
                        Button(action: handleAppleSignIn) {
                            HStack {
                                Image(systemName: "applelogo")
                                    .font(.system(size: 18))
                                Text("Continue with Apple")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.foreground)
                            .cornerRadius(12)
                        }
                        .disabled(isLoading)
                        
                        // Back Button
                        Button(action: {
                            withAnimation {
                                showLoginForm = false
                                email = ""
                                password = ""
                                errorMessage = nil
                            }
                        }) {
                            Text("Back")
                                .font(.system(size: 14))
                                .foregroundColor(.mutedForeground)
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    // Buttons (default view)
                    VStack(spacing: 16) {
                        // Create Account Button
                        Button(action: {
                            showCreateAccount = true
                        }) {
                            Text("Create Account")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(Color.primaryColor)
                                .cornerRadius(12)
                        }
                        
                        // Sign In Button
                        Button(action: {
                            withAnimation {
                                showLoginForm = true
                            }
                        }) {
                            Text("Sign In")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.foreground)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(Color.card)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.border, lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal, 24)
                }
                
                Spacer()
            }
        }
        .fullScreenCover(isPresented: $showCreateAccount) {
            CreateAccountFlowView()
                .environmentObject(authService)
        }
    }
    
    private func handleEmailLogin() {
        guard !email.isEmpty && !password.isEmpty else {
            errorMessage = "Please enter email and password"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await authService.signIn(email: email, password: password)
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
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
    
    private func handleAppleSignIn() {
        errorMessage = "Apple Sign-In coming soon"
    }
}

#Preview {
    SplashView()
        .environmentObject(AuthService())
}

