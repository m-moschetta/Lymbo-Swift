//
//  LymboApp.swift
//  Lymbo
//
//  Created on 2025
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct LymboApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authService = AuthService()
    
    var body: some Scene {
        WindowGroup {
            if authService.isAuthenticated {
                if authService.hasCompletedOnboarding {
                    MainTabView()
                        .environmentObject(authService)
                        .onAppear {
                            // Aggiorna location quando l'app si apre e l'utente è autenticato
                            Task {
                                await LocationService.shared.updateAndSaveLocation()
                            }
                        }
                } else {
                    CreateAccountFlowView()
                        .environmentObject(authService)
                }
            } else {
                SplashView()
                    .environmentObject(authService)
            }
        }
    }
}

