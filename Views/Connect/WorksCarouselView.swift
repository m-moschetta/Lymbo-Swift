//
//  WorksCarouselView.swift
//  Lymbo
//
//  Created on 2025
//

import SwiftUI

struct WorksCarouselView: View {
    let works: [String]
    @Binding var selectedIndex: Int
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(works.enumerated()), id: \.offset) { index, work in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedIndex = index
                        }
                    }) {
                        AsyncImage(url: URL(string: "https://picsum.photos/100/100?random=\(index + 100)")) { phase in
                            switch phase {
                            case .empty:
                                Color.muted
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            case .failure:
                                Color.muted
                            @unknown default:
                                Color.muted
                            }
                        }
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(selectedIndex == index ? Color.primaryColor : Color.clear, lineWidth: 3)
                        )
                        .scaleEffect(selectedIndex == index ? 1.05 : 1.0)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    WorksCarouselView(
        works: ["work1", "work2", "work3", "work4"],
        selectedIndex: .constant(0)
    )
}

