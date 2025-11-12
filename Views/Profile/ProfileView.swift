//
//  ProfileView.swift
//  Lymbo
//
//  Created on 2025
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileView: View {
    @StateObject private var authService = AuthService()
    @StateObject private var profileService = UserProfileService.shared
    @State private var showLogoutAlert = false
    @State private var showBadge = false
    @State private var showEditProfile = false
    @State private var userProfile: UserProfile?
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if isLoading {
                        ProgressView()
                            .padding(.top, 100)
                    } else {
                        // Profile Header
                        VStack(spacing: 16) {
                            // Profile Image
                            Button(action: {
                                // Show full image
                            }) {
                                Group {
                                    if let source = profileImageSourceTuple {
                                        CachedAsyncImage(url: source.url, storagePath: source.path) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                        } placeholder: {
                                            Image(systemName: "person.circle.fill")
                                                .font(.system(size: 100))
                                                .foregroundColor(.foreground)
                                        }
                                    } else {
                                        Image(systemName: "person.circle.fill")
                                            .font(.system(size: 100))
                                            .foregroundColor(.foreground)
                                    }
                                }
                                .frame(width: 120, height: 120)
                                .background(Color.muted)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.border, lineWidth: 2)
                                )
                            }
                            
                            VStack(spacing: 8) {
                                Text(displayName)
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.foreground)
                                
                                if let profession = userProfile?.profession, !profession.isEmpty {
                                    Text(profession)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.mutedForeground)
                                } else {
                                    Text("Update your profile to stand out")
                                        .font(.system(size: 16))
                                        .foregroundColor(.mutedForeground)
                                }
                            }
                            
                            // Bio
                            if let bio = userProfile?.bio, !bio.isEmpty {
                                Text(bio)
                                    .font(.system(size: 14))
                                    .foregroundColor(.mutedForeground)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                                    .padding(.top, 8)
                            }
                            
                            // Portfolio Works
                            let portfolioItems = portfolioMedia()
                            if !portfolioItems.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(Array(portfolioItems.enumerated()), id: \.offset) { _, item in
                                            CachedAsyncImage(url: item.url, storagePath: item.path) { image in
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                            } placeholder: {
                                                Rectangle()
                                                    .fill(Color.muted)
                                            }
                                            .frame(width: 80, height: 80)
                                            .cornerRadius(8)
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                                .padding(.top, 16)
                            }
                        
                            // My Badge Button
                            Button(action: {
                                if userProfile != nil {
                                    showBadge = true
                                }
                            }) {
                                HStack {
                                    Image(systemName: "star.fill")
                                    Text("My Badge")
                                }
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.accentColor)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Color.primaryColor)
                                .cornerRadius(8)
                            }
                            .disabled(userProfile == nil)
                        }
                        .padding(.top, 20)
                    
                    // Account Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Account")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.foreground)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 0) {
                            ProfileMenuItem(
                                icon: "person.fill",
                                title: "Edit Profile",
                                subtitle: "Update your photos and info",
                                action: {
                                    showEditProfile = true
                                }
                            )
                            
                            Divider()
                                .padding(.leading, 60)
                            
                            ProfileMenuItem(
                                icon: "chart.bar.fill",
                                title: "Stats",
                                subtitle: "View your activity stats",
                                action: {}
                            )
                            
                            Divider()
                                .padding(.leading, 60)
                            
                            ProfileMenuItem(
                                icon: "location.fill",
                                title: "Location",
                                subtitle: "Set your location",
                                action: {}
                            )
                            
                            Divider()
                                .padding(.leading, 60)
                            
                            ProfileMenuItem(
                                icon: "eye.fill",
                                title: "Profile Visibility",
                                subtitle: "Control who can see your profile",
                                action: {}
                            )
                            
                            Divider()
                                .padding(.leading, 60)
                            
                            ProfileMenuItem(
                                icon: "rectangle.portrait.and.arrow.right",
                                title: "Logout",
                                subtitle: "Sign out of your account",
                                action: {
                                    showLogoutAlert = true
                                }
                            )
                        }
                        .background(Color.card)
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                    }
                    
                        // Stats Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("This Week")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.foreground)
                                .padding(.horizontal, 20)
                            
                            HStack(spacing: 12) {
                                StatCard(title: "Connections", value: "12")
                                StatCard(title: "Profile Views", value: "48")
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.bottom, 40)
            }
            .background(Color.backgroundColor)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadUserProfile()
            }
            .onChange(of: profileImageCacheKey) { key in
                guard let key else { return }
                Task {
                    await ImageCache.shared.removeImage(forKey: key)
                }
            }
            .onChange(of: portfolioCacheKeys) { keys in
                Task {
                    for key in keys {
                        await ImageCache.shared.removeImage(forKey: key)
                    }
                }
            }
            .alert("Logout", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Logout", role: .destructive) {
                    do {
                        try authService.signOut()
                    } catch {
                        print("Error signing out: \(error)")
                    }
                }
            } message: {
                Text("Are you sure you want to logout?")
            }
            .sheet(isPresented: $showBadge) {
                if let profile = userProfile {
                    NavigationView {
                        BadgeCardView(profile: profile)
                    }
                }
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView()
                    .onDisappear {
                        // Ricarica il profilo dopo l'editing
                        loadUserProfile()
                    }
            }
        }
    }
    
    private var displayName: String {
        if let profile = userProfile {
            if let artistName = profile.artistName, !artistName.isEmpty {
                return artistName
            } else if let firstName = profile.firstName, let lastName = profile.lastName {
                return "\(firstName) \(lastName)"
            }
        }
        return userProfile?.displayName ?? "Your Name"
    }
    
    private var profileImageSourceTuple: (url: URL?, path: String?)? {
        let path = userProfile?.profileImagePath
        let url = userProfile?.profileImageURL.flatMap { URL(string: $0) }
        
        if path == nil && url == nil {
            return nil
        }
        return (url, path)
    }
    
    private func portfolioMedia() -> [(url: URL?, path: String?)] {
        guard let profile = userProfile else { return [] }
        let urls = profile.portfolioURLs ?? []
        let paths = profile.portfolioPaths ?? []
        let maxCount = max(urls.count, paths.count)
        
        return (0..<maxCount).map { index in
            let url = index < urls.count ? URL(string: urls[index]) : nil
            let path = index < paths.count ? paths[index] : nil
            return (url, path)
        }
    }
    
    private var profileImageCacheKey: String? {
        userProfile?.profileImagePath ?? userProfile?.profileImageURL
    }
    
    private var portfolioCacheKeys: [String] {
        if let paths = userProfile?.portfolioPaths, !paths.isEmpty {
            return paths
        }
        return userProfile?.portfolioURLs ?? []
    }
    
    private func loadUserProfile() {
        guard let uid = Auth.auth().currentUser?.uid else {
            isLoading = false
            return
        }
        
        Task {
            do {
                let profile = try await UserProfileService.shared.fetchUserProfile(uid: uid)
                await MainActor.run {
                    self.userProfile = profile
                    
                    // Debug: stampa gli URL per verificare che siano presenti
                    if let profileImageURL = profile?.profileImageURL {
                        print("📸 Profile Image URL: \(profileImageURL)")
                    } else {
                        print("⚠️ Profile Image URL is nil")
                    }
                    
                    if let profileImagePath = profile?.profileImagePath {
                        print("🗂️ Profile Image Path: \(profileImagePath)")
                    } else {
                        print("⚠️ Profile Image Path is nil")
                    }
                    
                    if let portfolioURLs = profile?.portfolioURLs {
                        print("🖼️ Portfolio URLs count: \(portfolioURLs.count)")
                        for (index, url) in portfolioURLs.enumerated() {
                            print("  [\(index)]: \(url)")
                        }
                    } else {
                        print("⚠️ Portfolio URLs is nil or empty")
                    }
                    
                    if let portfolioPaths = profile?.portfolioPaths {
                        print("🗂️ Portfolio paths count: \(portfolioPaths.count)")
                        for (index, path) in portfolioPaths.enumerated() {
                            print("  [\(index)]: \(path)")
                        }
                    } else {
                        print("⚠️ Portfolio paths is nil or empty")
                    }
                    
                    self.isLoading = false
                }
            } catch {
                print("Error loading profile: \(error)")
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
}

struct ProfileMenuItem: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.foreground)
                    .frame(width: 40, height: 40)
                    .background(Color.muted)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.foreground)
                    
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.mutedForeground)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.mutedForeground)
            }
            .padding(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.foreground)
            
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.mutedForeground)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.card)
        .cornerRadius(12)
    }
}

#Preview {
    ProfileView()
}
