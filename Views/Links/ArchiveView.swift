//
//  ArchiveView.swift
//  Lymbo
//
//  Created on 2025
//

import SwiftUI

struct ArchiveView: View {
    @State private var archivedCreatives = sampleArchivedCreatives
    @State private var pinnedCreatives: Set<String> = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("The Archive Tab allows you to save all the people you swiped right in the app. The last 100 Creatives you swipe right will be shown here.")
                    .font(.system(size: 14))
                    .foregroundColor(.mutedForeground)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                ForEach(archivedCreatives) { creative in
                    ArchiveCard(
                        creative: creative,
                        isPinned: pinnedCreatives.contains(creative.name),
                        onPin: {
                            if pinnedCreatives.contains(creative.name) {
                                pinnedCreatives.remove(creative.name)
                            } else {
                                pinnedCreatives.insert(creative.name)
                            }
                        }
                    )
                }
            }
            .padding(.vertical, 20)
        }
    }
}

struct ArchiveCard: View {
    let creative: Creative
    let isPinned: Bool
    let onPin: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Thumbnail
            AsyncImage(url: URL(string: "https://picsum.photos/100/100?random=\(creative.name.hash)")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.muted
            }
            .frame(width: 100, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Info
            VStack(alignment: .leading, spacing: 6) {
                Text(creative.name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.foreground)
                
                Text(creative.type)
                    .font(.system(size: 14))
                    .foregroundColor(.mutedForeground)
                
                Text(creative.position)
                    .font(.system(size: 12))
                    .foregroundColor(.mutedForeground)
            }
            
            Spacer()
            
            // Pin Button
            Button(action: onPin) {
                Image(systemName: isPinned ? "pin.fill" : "pin")
                    .font(.system(size: 18))
                    .foregroundColor(isPinned ? .primaryColor : .mutedForeground)
                    .frame(width: 44, height: 44)
                    .background(isPinned ? Color.primaryColor.opacity(0.1) : Color.inputBackground)
                    .clipShape(Circle())
            }
        }
        .padding(16)
        .background(Color.card)
        .cornerRadius(12)
        .padding(.horizontal, 20)
    }
}

let sampleArchivedCreatives: [Creative] = [
    Creative(
        name: "Lisa Anderson",
        type: "Fashion Designer",
        position: "4.5 km away",
        guild: "Fashion Collective",
        profileImage: "person.circle.fill",
        works: ["work1", "work2", "work3"],
        description: "Fashion designer"
    ),
    Creative(
        name: "David Lee",
        type: "Painter",
        position: "12.3 km away",
        guild: nil,
        profileImage: "person.circle.fill",
        works: ["work1", "work2"],
        description: "Painter"
    )
]

extension Creative: Identifiable {
    var id: String { name }
}

#Preview {
    ArchiveView()
}

