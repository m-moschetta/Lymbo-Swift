//
//  TutorialCardsView.swift
//  Lymbo
//
//  Created on 2025
//

import SwiftUI

struct TutorialCardsView: View {
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) var dismiss
    @State private var currentIndex = 0
    @State private var dragOffset: CGFloat = 0
    @State private var isCompleting = false
    
    let tutorialCards: [TutorialCard] = [
        TutorialCard(
            icon: "person.2.fill",
            title: "Connect",
            description: "Swipe right to like, left to pass. Find creative professionals that match your style and interests.",
            color: .primaryColor
        ),
        TutorialCard(
            icon: "link",
            title: "Links",
            description: "View your matches, chat with connections, and manage your network of creative professionals.",
            color: .primaryColor
        ),
        TutorialCard(
            icon: "calendar",
            title: "Events",
            description: "Discover and join events for creatives. Network, learn, and grow your creative community.",
            color: .primaryColor
        ),
        TutorialCard(
            icon: "person.fill",
            title: "Profile",
            description: "Manage your profile, showcase your work, and control your visibility in the Lymbo community.",
            color: .primaryColor
        )
    ]
    
    var body: some View {
        ZStack {
            Color.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress Indicator
                HStack(spacing: 8) {
                    ForEach(0..<tutorialCards.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentIndex ? Color.primaryColor : Color.muted)
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut, value: currentIndex)
                    }
                }
                .padding(.top, 60)
                .padding(.bottom, 40)
                
                // Cards Container
                GeometryReader { geometry in
                    ZStack {
                        ForEach(Array(tutorialCards.enumerated()), id: \.offset) { index, card in
                            if index >= currentIndex && index < currentIndex + 2 {
                                VStack {
                                    TutorialCardView(card: card)
                                    
                                    // Mostra pulsante "Get Started" solo nell'ultima card
                                    if index == tutorialCards.count - 1 {
                                        Button(action: {
                                            completeTutorial()
                                        }) {
                                            HStack {
                                                if isCompleting {
                                                    ProgressView()
                                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                } else {
                                                    Text("Get Started")
                                                        .font(.system(size: 18, weight: .bold))
                                                }
                                            }
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 18)
                                            .background(isCompleting ? Color.gray : Color.primaryColor)
                                            .cornerRadius(12)
                                        }
                                        .disabled(isCompleting)
                                        .padding(.horizontal, 40)
                                        .padding(.top, 20)
                                    }
                                }
                                .frame(width: geometry.size.width - 40)
                                .offset(x: index == currentIndex ? dragOffset : 0)
                                .scaleEffect(index == currentIndex ? 1.0 : 0.95)
                                .opacity(index == currentIndex ? 1.0 : 0.6)
                                .zIndex(Double(tutorialCards.count - index))
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            if index == currentIndex {
                                                dragOffset = value.translation.width
                                            }
                                        }
                                        .onEnded { value in
                                            if index == currentIndex {
                                                let threshold: CGFloat = 100
                                                if value.translation.width > threshold {
                                                    // Swipe right - go to next
                                                    withAnimation(.spring()) {
                                                        goToNext()
                                                    }
                                                } else if value.translation.width < -threshold {
                                                    // Swipe left - go to previous
                                                    withAnimation(.spring()) {
                                                        goToPrevious()
                                                    }
                                                } else {
                                                    // Snap back
                                                    withAnimation(.spring()) {
                                                        dragOffset = 0
                                                    }
                                                }
                                            }
                                        }
                                )
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                // Navigation Buttons
                HStack(spacing: 16) {
                    if currentIndex > 0 {
                        Button(action: {
                            withAnimation(.spring()) {
                                goToPrevious()
                            }
                        }) {
                            Text("Previous")
                                .font(.system(size: 16, weight: .medium))
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
                    }
                    
                    Button(action: {
                        if currentIndex < tutorialCards.count - 1 {
                            withAnimation(.spring()) {
                                goToNext()
                            }
                        } else {
                            // Complete tutorial
                            completeTutorial()
                        }
                    }) {
                        HStack {
                            if isCompleting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text(currentIndex < tutorialCards.count - 1 ? "Next" : "Get Started")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(isCompleting ? Color.gray : Color.primaryColor)
                        .cornerRadius(12)
                    }
                    .disabled(isCompleting)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func goToNext() {
        if currentIndex < tutorialCards.count - 1 {
            currentIndex += 1
            dragOffset = 0
        }
    }
    
    private func goToPrevious() {
        if currentIndex > 0 {
            currentIndex -= 1
            dragOffset = 0
        }
    }
    
    private func completeTutorial() {
        isCompleting = true
        
        Task {
            // Assicurati che il flag sia salvato nel database
            guard let uid = authService.currentUser?.uid else {
                isCompleting = false
                return
            }
            
            do {
                // Aggiorna il flag nel database
                try await UserProfileService.shared.updateUserProfile(uid: uid, updates: [
                    "hasCompletedOnboarding": true
                ])
                
                // Aggiorna lo stato locale
                await MainActor.run {
                    authService.hasCompletedOnboarding = true
                    isCompleting = false
                    // L'app mostrerà automaticamente MainTabView perché hasCompletedOnboarding è true
                }
            } catch {
                print("Error completing tutorial: \(error)")
                await MainActor.run {
                    isCompleting = false
                    // Prova comunque ad aggiornare lo stato locale
                    authService.hasCompletedOnboarding = true
                }
            }
        }
    }
}

struct TutorialCard {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

struct TutorialCardView: View {
    let card: TutorialCard
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Icon
            Image(systemName: card.icon)
                .font(.system(size: 80))
                .foregroundColor(card.color)
            
            // Title
            Text(card.title)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.foreground)
            
            // Description
            Text(card.description)
                .font(.system(size: 18))
                .foregroundColor(.mutedForeground)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 40)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.card)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
    }
}

#Preview {
    TutorialCardsView()
}

