//
//  BadgeCardView.swift
//  Lymbo
//
//  Created on 2025
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct BadgeCardView: View {
    let profile: UserProfile
    @Environment(\.dismiss) var dismiss
    
    @State private var isFlipped = false
    @State private var flipRotation: Double = 0
    @State private var isDraggingFlip = false
    
    var body: some View {
        ZStack {
            Color.backgroundColor
                .ignoresSafeArea()
            
            GeometryReader { geometry in
                VStack(spacing: 24) {
                    // Badge Card con flip
                    GeometryReader { cardGeometry in
                        ZStack {
                            // Front Side - Profile Info
                            ZStack {
                                Color.card
                                    .cornerRadius(20)
                                
                                VStack(spacing: 0) {
                                    // Header con gradiente
                                    ZStack {
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.primaryColor,
                                                Color.primaryColor.opacity(0.8)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                        
                                        VStack(spacing: 16) {
                                            // Profile Image
                                            Group {
                                                if let source = profileImageSource {
                                                    CachedAsyncImage(url: source.url, storagePath: source.path) { image in
                                                        image
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fill)
                                                    } placeholder: {
                                                        Image(systemName: "person.circle.fill")
                                                            .font(.system(size: 80))
                                                            .foregroundColor(.white)
                                                    }
                                                } else {
                                                    Image(systemName: "person.circle.fill")
                                                        .font(.system(size: 80))
                                                        .foregroundColor(.white)
                                                }
                                            }
                                            .frame(width: 120, height: 120)
                                            .background(Color.white.opacity(0.2))
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white.opacity(0.3), lineWidth: 3)
                                            )
                                            
                                            // Name
                                            Text(displayName)
                                                .font(.system(size: 32, weight: .bold))
                                                .foregroundColor(.white)
                                            
                                            // Profession
                                            if let profession = profile.profession, !profession.isEmpty {
                                                Text(profession)
                                                    .font(.system(size: 18, weight: .medium))
                                                    .foregroundColor(.white.opacity(0.9))
                                            }
                                            
                                            // Location
                                            if let location = profile.location, !location.isEmpty {
                                                HStack(spacing: 6) {
                                                    Image(systemName: "location.fill")
                                                        .font(.system(size: 14))
                                                    Text(location)
                                                        .font(.system(size: 16))
                                                }
                                                .foregroundColor(.white.opacity(0.9))
                                                .padding(.top, 4)
                                            }
                                        }
                                        .padding(.top, 40)
                                        .padding(.bottom, 30)
                                    }
                                    
                                    // Body con informazioni
                                    ScrollView {
                                        VStack(spacing: 20) {
                                            // Bio
                                            if let bio = profile.bio, !bio.isEmpty {
                                                VStack(alignment: .leading, spacing: 8) {
                                                    Text("About")
                                                        .font(.system(size: 16, weight: .semibold))
                                                        .foregroundColor(.foreground)
                                                    
                                                    Text(bio)
                                                        .font(.system(size: 14))
                                                        .foregroundColor(.mutedForeground)
                                                        .lineSpacing(4)
                                                }
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                            
                                            // Additional Info
                                            VStack(spacing: 12) {
                                                if let firstName = profile.firstName, let lastName = profile.lastName {
                                                    InfoRow(icon: "person.fill", label: "Name", value: "\(firstName) \(lastName)")
                                                }
                                                
                                                if let artistName = profile.artistName, !artistName.isEmpty {
                                                    InfoRow(icon: "paintbrush.fill", label: "Artist Name", value: artistName)
                                                }
                                                
                                                if let dateOfBirth = profile.dateOfBirth {
                                                    InfoRow(icon: "calendar", label: "Date of Birth", value: formatDate(dateOfBirth.dateValue()))
                                                }
                                                
                                                InfoRow(icon: "envelope.fill", label: "Email", value: profile.email)
                                            }
                                        }
                                        .padding(24)
                                    }
                                }
                            }
                            .rotation3DEffect(
                                .degrees(isFlipped ? flipRotation : -180 + flipRotation),
                                axis: (x: 0, y: 1, z: 0),
                                perspective: 0.6
                            )
                            .opacity({
                                if !isFlipped {
                                    return flipRotation >= 90 ? 1.0 : 0.0
                                } else {
                                    return flipRotation >= -90 ? 1.0 : 0.0
                                }
                            }())
                            
                            // Back Side - First Portfolio Image
                            ZStack {
                                if let firstPortfolioItem = firstPortfolioItem {
                                    CachedAsyncImage(url: firstPortfolioItem.url, storagePath: firstPortfolioItem.path) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Color.muted
                                    }
                                    .frame(width: cardGeometry.size.width, height: cardGeometry.size.height)
                                    .clipped()
                                    .cornerRadius(20)
                                } else {
                                    Color.muted
                                        .cornerRadius(20)
                                    
                                    VStack {
                                        Image(systemName: "photo")
                                            .font(.system(size: 60))
                                            .foregroundColor(.mutedForeground)
                                        Text("No portfolio image")
                                            .font(.system(size: 16))
                                            .foregroundColor(.mutedForeground)
                                    }
                                }
                                
                                // Eye Icon per flip
                                VStack {
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                                isFlipped.toggle()
                                                flipRotation = 0
                                            }
                                        }) {
                                            Image(systemName: "eye.fill")
                                                .font(.system(size: 20, weight: .medium))
                                                .foregroundColor(.foreground)
                                                .frame(width: 44, height: 44)
                                                .background(Color.muted)
                                                .clipShape(Circle())
                                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                                        }
                                        .padding(.top, 16)
                                        .padding(.trailing, 16)
                                    }
                                    Spacer()
                                }
                                .zIndex(1000)
                            }
                            .rotation3DEffect(
                                .degrees(isFlipped ? 180 + flipRotation : flipRotation),
                                axis: (x: 0, y: 1, z: 0),
                                perspective: 0.6
                            )
                            .opacity({
                                if !isFlipped {
                                    return flipRotation < 90 ? 1.0 : 0.0
                                } else {
                                    return flipRotation < -90 ? 1.0 : 0.0
                                }
                            }())
                        }
                        .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
                        .gesture(
                            DragGesture(minimumDistance: 10)
                                .onChanged { value in
                                    if !isFlipped {
                                        // Se si trascina verso destra, gestisci la rotazione
                                        if value.translation.width > 0 {
                                            let dragProgress = value.translation.width / cardGeometry.size.width
                                            flipRotation = Double(dragProgress * 180)
                                            flipRotation = max(0, min(180, flipRotation))
                                            isDraggingFlip = true
                                        }
                                    }
                                }
                                .onEnded { value in
                                    if !isFlipped && isDraggingFlip {
                                        let dragProgress = value.translation.width / cardGeometry.size.width
                                        let velocity = value.predictedEndTranslation.width / cardGeometry.size.width
                                        
                                        if dragProgress > 0.5 || velocity > 0.5 {
                                            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                                isFlipped = true
                                                flipRotation = 0
                                            }
                                        } else {
                                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                                flipRotation = 0
                                            }
                                        }
                                        isDraggingFlip = false
                                    }
                                }
                        )
                    }
                    .frame(height: 500)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Close Button
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Close")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.primaryColor)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("My Badge")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var displayName: String {
        if let artistName = profile.artistName, !artistName.isEmpty {
            return artistName
        } else if let firstName = profile.firstName, let lastName = profile.lastName {
            return "\(firstName) \(lastName)"
        }
        return profile.displayName
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
    
    private var profileImageSource: (url: URL?, path: String?)? {
        let path = profile.profileImagePath
        let url = profile.profileImageURL.flatMap { URL(string: $0) }
        
        if path == nil && url == nil {
            return nil
        }
        return (url, path)
    }
    
    private var firstPortfolioItem: (url: URL?, path: String?)? {
        let portfolioItems = portfolioMedia()
        return portfolioItems.first
    }
    
    private func portfolioMedia() -> [(url: URL?, path: String?)] {
        let urls = profile.portfolioURLs ?? []
        let paths = profile.portfolioPaths ?? []
        let maxCount = max(urls.count, paths.count)
        
        return (0..<maxCount).map { index in
            let url = index < urls.count ? URL(string: urls[index]) : nil
            let path = index < paths.count ? paths[index] : nil
            return (url, path)
        }
    }
}

struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.mutedForeground)
                .frame(width: 24)
            
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.mutedForeground)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14))
                .foregroundColor(.foreground)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationView {
        BadgeCardView(profile: UserProfile(
            id: "preview",
            email: "test@example.com",
            displayName: "John Doe",
            firstName: "John",
            lastName: "Doe",
            artistName: nil,
            dateOfBirth: Timestamp(date: Date()),
            bio: "Creative designer passionate about visual storytelling",
            profileImageURL: nil,
            profileImagePath: nil,
            location: nil,
            profession: "UI/UX Designer",
            portfolioURL: nil,
            portfolioURLs: nil,
            portfolioPaths: nil,
            hasCompletedOnboarding: true,
            preferences: nil,
            createdAt: Timestamp(),
            updatedAt: Timestamp()
        ))
    }
}
