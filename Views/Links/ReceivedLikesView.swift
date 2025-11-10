//
//  ReceivedLikesView.swift
//  Lymbo
//
//  Created on 2025
//

import SwiftUI

struct ReceivedLikesView: View {
    let receivedLikes = sampleReceivedLikes
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Every day you'll see 5 to 10 random profiles out of the creatives that have liked you in the past 30 days.")
                    .font(.system(size: 14))
                    .foregroundColor(.mutedForeground)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                ForEach(receivedLikes) { like in
                    ConnectionQuickCard(creative: like)
                }
            }
            .padding(.vertical, 20)
        }
    }
}

struct ConnectionQuickCard: View {
    let creative: Creative
    
    var body: some View {
        HStack(spacing: 16) {
            // Profile Image
            AsyncImage(url: URL(string: "https://picsum.photos/80/80?random=\(creative.name.hash)")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.muted
            }
            .frame(width: 80, height: 80)
            .clipShape(Circle())
            
            // Info
            VStack(alignment: .leading, spacing: 6) {
                Text(creative.name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.foreground)
                
                Text(creative.type)
                    .font(.system(size: 14))
                    .foregroundColor(.mutedForeground)
                
                if let guild = creative.guild {
                    Text(guild)
                        .font(.system(size: 12))
                        .foregroundColor(.mutedForeground)
                }
            }
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: 12) {
                Button(action: {
                    // Pass
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18))
                        .foregroundColor(.mutedForeground)
                        .frame(width: 44, height: 44)
                        .background(Color.inputBackground)
                        .clipShape(Circle())
                }
                
                Button(action: {
                    // Like
                }) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.accentColor)
                        .frame(width: 44, height: 44)
                        .background(Color.primaryColor)
                        .clipShape(Circle())
                }
            }
        }
        .padding(16)
        .background(Color.card)
        .cornerRadius(12)
        .padding(.horizontal, 20)
    }
}

let sampleReceivedLikes: [Creative] = [
    Creative(
        name: "Emma Wilson",
        type: "Illustrator",
        position: "3.2 km away",
        guild: "Digital Arts Guild",
        profileImage: "person.circle.fill",
        works: ["work1", "work2"],
        description: "Digital illustrator"
    ),
    Creative(
        name: "Michael Brown",
        type: "Graphic Designer",
        position: "7.8 km away",
        guild: nil,
        profileImage: "person.circle.fill",
        works: ["work1"],
        description: "Graphic designer"
    )
]

#Preview {
    ReceivedLikesView()
}

