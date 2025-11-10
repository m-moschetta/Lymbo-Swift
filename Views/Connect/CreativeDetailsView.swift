//
//  CreativeDetailsView.swift
//  Lymbo
//
//  Created on 2025
//

import SwiftUI

struct CreativeDetailsView: View {
    let creative: Creative
    let onBack: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Back Button
                Button(action: onBack) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.foreground)
                }
                .padding(.top)
                
                // Profile Header
                HStack(spacing: 16) {
                    Image(systemName: creative.profileImage)
                        .font(.system(size: 60))
                        .foregroundColor(.foreground)
                        .frame(width: 80, height: 80)
                        .background(Color.muted)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(creative.name)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.foreground)
                        
                        Text(creative.type)
                            .font(.system(size: 18))
                            .foregroundColor(.mutedForeground)
                        
                        if let guild = creative.guild {
                            Text(guild)
                                .font(.system(size: 16))
                                .foregroundColor(.mutedForeground)
                        }
                        
                        HStack {
                            Image(systemName: "location.fill")
                            Text(creative.position)
                        }
                        .font(.system(size: 14))
                        .foregroundColor(.mutedForeground)
                    }
                    
                    Spacer()
                }
                
                Divider()
                
                // Description
                Text("About")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.foreground)
                
                Text(creative.description)
                    .font(.system(size: 16))
                    .foregroundColor(.mutedForeground)
                    .lineSpacing(4)
                
                // Works Gallery
                Text("Portfolio")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.foreground)
                    .padding(.top)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(Array(creative.works.enumerated()), id: \.offset) { index, _ in
                        AsyncImage(url: URL(string: "https://picsum.photos/200/200?random=\(index)")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color.muted
                        }
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
            .padding(20)
        }
        .background(Color.backgroundColor)
    }
}

#Preview {
    CreativeDetailsView(
        creative: sampleCreatives[0],
        onBack: {}
    )
}

