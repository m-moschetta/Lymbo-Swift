//
//  ConnectView.swift
//  Lymbo
//
//  Created on 2025
//

import SwiftUI

struct ConnectView: View {
    @State private var currentCreativeIndex = 0
    @State private var selectedWorkIndex = 0
    @State private var showDetails = false
    @State private var showPreferences = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("Connect")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.foreground)
                        
                        Spacer()
                        
                        Button(action: {
                            showPreferences.toggle()
                        }) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 20))
                                .foregroundColor(.foreground)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Main Card Area
                    SwipeableCardView(
                        creative: sampleCreatives[currentCreativeIndex],
                        selectedWorkIndex: selectedWorkIndex,
                        onSwipe: { direction in
                            handleSwipe(direction)
                        },
                        onTapImage: {
                            // Handle profile image tap - could show full screen
                            showDetails.toggle()
                        },
                        onSelectWork: { index in
                            // Update selected work index when thumbnail is tapped
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedWorkIndex = index
                            }
                        }
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showPreferences) {
                PreferencesView()
            }
            .fullScreenCover(isPresented: $showDetails) {
                CreativeDetailsView(
                    creative: sampleCreatives[currentCreativeIndex],
                    onBack: {
                        showDetails = false
                    }
                )
            }
        }
    }
    
    private func handleSwipe(_ direction: SwipeDirection) {
        switch direction {
        case .right: // Like
            // Move to Links/Chats
            withAnimation {
                currentCreativeIndex = min(currentCreativeIndex + 1, sampleCreatives.count - 1)
                selectedWorkIndex = 0 // Reset to first work
            }
        case .left: // Pass
            // Just move to next
            withAnimation {
                currentCreativeIndex = min(currentCreativeIndex + 1, sampleCreatives.count - 1)
                selectedWorkIndex = 0 // Reset to first work
            }
        case .up: // Show without overlays
            // Toggle overlay visibility
            break
        case .down: // Restore overlays
            // Restore overlay visibility
            break
        }
    }
}

enum SwipeDirection {
    case left, right, up, down
}

// Sample data
let sampleCreatives: [Creative] = [
    Creative(
        name: "Alex Johnson",
        type: "Photographer",
        position: "2.5 km away",
        guild: "Visual Arts Collective",
        profileImage: "person.circle.fill",
        works: ["work1", "work2", "work3", "work4"],
        description: "Passionate photographer specializing in portrait and street photography."
    ),
    Creative(
        name: "Sarah Chen",
        type: "Video Designer",
        position: "5.1 km away",
        guild: nil,
        profileImage: "person.circle.fill",
        works: ["work1", "work2", "work3"],
        description: "Creative video designer with expertise in motion graphics and animation."
    )
]

struct Creative {
    let name: String
    let type: String
    let position: String
    let guild: String?
    let profileImage: String
    let works: [String]
    let description: String
}

#Preview {
    ConnectView()
}

