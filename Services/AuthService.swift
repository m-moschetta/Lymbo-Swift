//
//  AuthService.swift
//  Lymbo
//
//  Created on 2025
//

import Foundation
import FirebaseAuth
import Combine
import CryptoKit

@MainActor
final class AuthService: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var hasCompletedOnboarding = false
    
    nonisolated(unsafe) private var authStateHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.currentUser = user
                self?.isAuthenticated = user != nil
                
                // Verifica se l'onboarding è completato
                if let uid = user?.uid {
                    await self?.checkOnboardingStatus(uid: uid)
                    
                    // Aggiorna automaticamente la location quando l'utente è autenticato
                    await self?.updateLocationIfAuthorized()
                } else {
                    self?.hasCompletedOnboarding = false
                }
            }
        }
    }
    
    private func updateLocationIfAuthorized() async {
        let locationService = LocationService.shared
        
        // Controlla se i permessi sono già stati concessi
        if locationService.authorizationStatus == .authorizedWhenInUse || 
           locationService.authorizationStatus == .authorizedAlways {
            // Aggiorna e salva la location
            await locationService.updateAndSaveLocation()
        } else if locationService.authorizationStatus == .notDetermined {
            // Richiedi permessi (ma non bloccare se l'utente rifiuta)
            locationService.requestAuthorization()
        }
    }
    
    private func checkOnboardingStatus(uid: String) async {
        do {
            if let profile = try await UserProfileService.shared.fetchUserProfile(uid: uid) {
                // Controlla prima il flag esplicito, poi fallback su profession/bio
                if let hasCompleted = profile.hasCompletedOnboarding {
                    self.hasCompletedOnboarding = hasCompleted
                } else {
                    // Se il flag non esiste, controlla se ha dati essenziali
                    // Se ha profession o bio, considera completato (utente vecchio)
                    // Altrimenti non è completato
                    self.hasCompletedOnboarding = profile.profession != nil || !(profile.bio?.isEmpty ?? true)
                }
            } else {
                // Se il profilo non esiste, l'onboarding non è completato
                self.hasCompletedOnboarding = false
            }
        } catch {
            // In caso di errore, considera non completato per sicurezza
            self.hasCompletedOnboarding = false
        }
    }
    
    // Note: authStateHandle viene gestito automaticamente da Firebase quando l'app termina
    
    // MARK: - Email/Password Authentication
    
    func signUp(email: String, password: String, displayName: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        
        // Update display name
        let changeRequest = result.user.createProfileChangeRequest()
        changeRequest.displayName = displayName
        try await changeRequest.commitChanges()
        
        // Create user profile in Firestore
        try await UserProfileService.shared.createUserProfile(
            uid: result.user.uid,
            email: email,
            displayName: displayName
        )
    }
    
    func signIn(email: String, password: String) async throws {
        _ = try await Auth.auth().signIn(withEmail: email, password: password)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
        hasCompletedOnboarding = false
    }
    
    // MARK: - Google Sign In
    
    func signInWithGoogle(idToken: String, accessToken: String) async throws {
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        let result = try await Auth.auth().signIn(with: credential)
        
        // Create or update user profile
        if let email = result.user.email, let displayName = result.user.displayName {
            try await UserProfileService.shared.createOrUpdateUserProfile(
                uid: result.user.uid,
                email: email,
                displayName: displayName
            )
        }
    }
    
    // MARK: - Apple Sign In
    
    func signInWithApple(idToken: String, nonce: String) async throws {
        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idToken, rawNonce: nonce)
        let result = try await Auth.auth().signIn(with: credential)
        
        // Create or update user profile
        if let email = result.user.email, let displayName = result.user.displayName {
            try await UserProfileService.shared.createOrUpdateUserProfile(
                uid: result.user.uid,
                email: email,
                displayName: displayName
            )
        }
    }
    
    // MARK: - Password Reset
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
}

