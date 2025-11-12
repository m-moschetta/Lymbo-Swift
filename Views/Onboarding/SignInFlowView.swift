//
//  SignInFlowView.swift
//  Lymbo
//
//  Created on 2025
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

struct SignInFlowView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var authService = AuthService()
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Welcome back!")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.foreground)
                        
                        Text("Sign in to continue")
                            .font(.system(size: 16))
                            .foregroundColor(.mutedForeground)
                    }
                    .padding(.top, 60)
                    
                    // Google Sign In Button (Default)
                    Button(action: handleGoogleSignIn) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "globe")
                                    .font(.system(size: 18))
                                Text("Continue with Google")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(isLoading ? Color.gray : Color.primaryColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(isLoading)
                    .padding(.horizontal, 24)
                    
                    // Apple Sign In Button
                    Button(action: handleAppleSignIn) {
                        HStack {
                            Image(systemName: "applelogo")
                                .font(.system(size: 18))
                            Text("Continue with Apple")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.foreground)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(isLoading)
                    .padding(.horizontal, 24)
                    
                    // Error Message
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .padding(.horizontal, 24)
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                }
            }
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
            errorMessage = "Google Sign-In configuration error. Please check GoogleService-Info.plist"
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
                    self.dismiss()
                } catch {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func handleAppleSignIn() {
        // TODO: Implementare Apple Sign-In
        errorMessage = "Apple Sign-In coming soon"
    }
}

struct EmailSignInView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var authService = AuthService()
    @State private var showGoogleSignIn = false
    @State private var showAppleSignIn = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Sign in with")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.foreground)
                    .padding(.top, 40)
                
                // Google Sign In
                Button(action: {
                    showGoogleSignIn = true
                }) {
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
                
                // Apple Sign In
                Button(action: {
                    showAppleSignIn = true
                }) {
                    HStack {
                        Image(systemName: "applelogo")
                        Text("Continue with Apple")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.foreground)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .background(Color.backgroundColor)
            .navigationTitle("Sign In")
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
}

#Preview {
    SignInFlowView()
}

