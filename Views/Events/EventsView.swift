//
//  EventsView.swift
//  Lymbo
//
//  Created on 2025
//

import SwiftUI

struct EventsView: View {
    let events = sampleEvents
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(events) { event in
                        EventCard(event: event)
                    }
                }
                .padding(20)
            }
            .background(Color.backgroundColor)
            .navigationTitle("Events")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct EventCard: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Event Image
            AsyncImage(url: URL(string: "https://picsum.photos/400/200?random=\(event.id.hashValue)")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.muted
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Event Info
            VStack(alignment: .leading, spacing: 8) {
                Text(event.title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.foreground)
                
                HStack {
                    Image(systemName: "calendar")
                    Text(event.date)
                }
                .font(.system(size: 14))
                .foregroundColor(.mutedForeground)
                
                HStack {
                    Image(systemName: "location.fill")
                    Text(event.location)
                }
                .font(.system(size: 14))
                .foregroundColor(.mutedForeground)
                
                Text(event.description)
                    .font(.system(size: 14))
                    .foregroundColor(.mutedForeground)
                    .lineLimit(3)
                
                Button(action: {
                    // Register for event
                }) {
                    Text("Register")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.accentColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.primaryColor)
                        .cornerRadius(8)
                }
                .padding(.top, 8)
            }
            .padding(16)
        }
        .background(Color.card)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct Event: Identifiable {
    let id = UUID()
    let title: String
    let date: String
    let location: String
    let description: String
}

let sampleEvents: [Event] = [
    Event(
        title: "Creative Meetup",
        date: "March 15, 2025",
        location: "Milan, Italy",
        description: "Join us for an evening of networking and inspiration with fellow creatives from the Lymbo community."
    ),
    Event(
        title: "Portfolio Review Session",
        date: "March 22, 2025",
        location: "Rome, Italy",
        description: "Get feedback on your portfolio from industry professionals and peers."
    )
]

#Preview {
    EventsView()
}

