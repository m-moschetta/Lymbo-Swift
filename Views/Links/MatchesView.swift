//
//  MatchesView.swift
//  Lymbo
//
//  Created on 2025
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct MatchesView: View {
    @StateObject private var matchService = MatchService.shared
    @State private var matches: [Match] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundColor
                    .ignoresSafeArea()
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else if matches.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.mutedForeground)
                        
                        Text("No Matches Yet")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.foreground)
                        
                        Text("Start swiping to find your creative match!")
                            .font(.system(size: 16))
                            .foregroundColor(.mutedForeground)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(matches) { match in
                                MatchCardView(match: match)
                            }
                        }
                        .padding()
                    }
                }
                
                if let errorMessage = errorMessage {
                    VStack {
                        Spacer()
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.card)
                            .cornerRadius(8)
                            .padding()
                    }
                }
            }
            .navigationTitle("Matches")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadMatches()
            }
        }
    }
    
    private func loadMatches() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            errorMessage = "Please sign in to view matches"
            isLoading = false
            return
        }
        
        Task {
            do {
                let fetchedMatches = try await matchService.fetchMatches(for: currentUserID)
                await MainActor.run {
                    self.matches = fetchedMatches
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}

struct MatchCardView: View {
    let match: Match
    @State private var otherUserProfile: UserProfile?
    @State private var isLoading = true
    
    var body: some View {
        HStack(spacing: 16) {
            // Profile Image
            if let source = profileImageSource {
                CachedAsyncImage(url: source.url, storagePath: source.path) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.mutedForeground)
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.border, lineWidth: 2)
                )
            } else {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.mutedForeground)
                    .frame(width: 60, height: 60)
                    .background(Color.muted)
                    .clipShape(Circle())
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(otherUserProfile?.displayName ?? "Loading...")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.foreground)
                
                if let profession = otherUserProfile?.profession {
                    Text(profession)
                        .font(.system(size: 14))
                        .foregroundColor(.mutedForeground)
                }
                
                Text("Matched \(formatDate(match.matchedAt.dateValue()))")
                    .font(.system(size: 12))
                    .foregroundColor(.mutedForeground)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.mutedForeground)
        }
        .padding()
        .background(Color.card)
        .cornerRadius(12)
        .onAppear {
            loadUserProfile()
        }
    }
    
    private func loadUserProfile() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let otherUserID = match.getOtherUserID(currentUserID: currentUserID)
        
        Task {
            do {
                let profile = try await UserProfileService.shared.fetchUserProfile(uid: otherUserID)
                await MainActor.run {
                    self.otherUserProfile = profile
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private var profileImageSource: (url: URL?, path: String?)? {
        guard let profile = otherUserProfile else { return nil }
        let path = profile.profileImagePath
        let url = profile.profileImageURL.flatMap { URL(string: $0) }
        if path == nil && url == nil {
            return nil
        }
        return (url, path)
    }
}

#Preview {
    MatchesView()
}
