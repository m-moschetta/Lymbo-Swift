//
//  EventsView.swift
//  Lymbo
//
//  Created on 2025
//

import SwiftUI

struct EventsView: View {
    @State private var selectedCategory: String = "All"
    let categories = ["All", "Music", "Art", "Food", "Sports"]
    
    var filteredEvents: [Event] {
        if selectedCategory == "All" {
            return sampleEvents
        }
        return sampleEvents.filter { $0.category == selectedCategory }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Header
                        HStack {
                            Text("Discover Events")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(.foreground)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .padding(.bottom, 16)
                        
                        // Category Filters
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(categories, id: \.self) { category in
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            selectedCategory = category
                                        }
                                    }) {
                                        Text(category)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(selectedCategory == category ? .accentColor : .foreground)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(selectedCategory == category ? Color.primaryColor : Color.clear)
                                            .cornerRadius(20)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.bottom, 20)
                        
                        // Events List
                        VStack(spacing: 20) {
                            ForEach(filteredEvents) { event in
                                EventCard(event: event)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct EventCard: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Event Image with overlays
            ZStack(alignment: .topLeading) {
                AsyncImage(url: URL(string: "https://picsum.photos/400/250?random=\(event.id.hashValue)")) { phase in
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
                .frame(height: 250)
                .clipped()
                
                // Likes count icon (top left)
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.primaryColor.opacity(0.8))
                            .frame(width: 32, height: 32)
                        
                        Text("\(event.likesCount)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.accentColor)
                    }
                    .padding(.leading, 12)
                    .padding(.top, 12)
                    
                    Spacer()
                }
                
                // Category tag (top right)
                HStack {
                    Spacer()
                    
                    Text(event.category)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.foreground)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.accentColor.opacity(0.9))
                        .cornerRadius(8)
                        .padding(.trailing, 12)
                        .padding(.top, 12)
                }
            }
            
            // Event Details
            VStack(alignment: .leading, spacing: 12) {
                // Title
                Text(event.title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.foreground)
                
                // Location, Time, Attending
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.mutedForeground)
                        Text(event.location)
                            .font(.system(size: 14))
                            .foregroundColor(.mutedForeground)
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.mutedForeground)
                        Text(event.time)
                            .font(.system(size: 14))
                            .foregroundColor(.mutedForeground)
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.mutedForeground)
                        Text("\(event.attendingCount) attending")
                            .font(.system(size: 14))
                            .foregroundColor(.mutedForeground)
                    }
                }
                
                // Likes that are going
                if !event.likesGoing.isEmpty {
                    HStack(spacing: 8) {
                        // Profile pictures
                        HStack(spacing: -8) {
                            ForEach(Array(event.likesGoing.prefix(2).enumerated()), id: \.offset) { index, profile in
                                AsyncImage(url: URL(string: "https://picsum.photos/32/32?random=\(profile.name.hash)")) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Image(systemName: "person.circle.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(.mutedForeground)
                                }
                                .frame(width: 32, height: 32)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.card, lineWidth: 2)
                                )
                            }
                        }
                        
                        // Names text
                        if event.likesGoing.count == 1 {
                            Text("\(event.likesGoing[0].name) is going")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.foreground)
                        } else if event.likesGoing.count == 2 {
                            Text("\(event.likesGoing[0].name) & \(event.likesGoing[1].name) are going")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.foreground)
                        } else {
                            Text("\(event.likesGoing[0].name), \(event.likesGoing[1].name) & \(event.likesGoing.count - 2) others are going")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.foreground)
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 4)
                }
            }
            .padding(16)
        }
        .background(Color.card)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct EventProfile {
    let name: String
    let profileImage: String
}

struct Event: Identifiable {
    let id = UUID()
    let title: String
    let category: String
    let location: String
    let time: String
    let attendingCount: Int
    let likesCount: Int
    let likesGoing: [EventProfile]
}

let sampleEvents: [Event] = [
    Event(
        title: "Jazz Night at Blue Note",
        category: "Music",
        location: "Blue Note, Downtown",
        time: "Tonight, 8:00 PM",
        attendingCount: 45,
        likesCount: 12,
        likesGoing: [
            EventProfile(name: "Emma", profileImage: "person.circle.fill"),
            EventProfile(name: "Alex", profileImage: "person.circle.fill")
        ]
    ),
    Event(
        title: "Art Exhibition Opening",
        category: "Art",
        location: "Modern Art Gallery, City Center",
        time: "Tomorrow, 6:00 PM",
        attendingCount: 32,
        likesCount: 8,
        likesGoing: [
            EventProfile(name: "Sarah", profileImage: "person.circle.fill")
        ]
    ),
    Event(
        title: "Food Festival 2025",
        category: "Food",
        location: "Central Park",
        time: "Saturday, 12:00 PM",
        attendingCount: 120,
        likesCount: 25,
        likesGoing: [
            EventProfile(name: "Marco", profileImage: "person.circle.fill"),
            EventProfile(name: "Lisa", profileImage: "person.circle.fill"),
            EventProfile(name: "Tom", profileImage: "person.circle.fill")
        ]
    ),
    Event(
        title: "Basketball Tournament",
        category: "Sports",
        location: "Sports Arena",
        time: "Sunday, 2:00 PM",
        attendingCount: 67,
        likesCount: 15,
        likesGoing: [
            EventProfile(name: "Mike", profileImage: "person.circle.fill"),
            EventProfile(name: "Anna", profileImage: "person.circle.fill")
        ]
    ),
    Event(
        title: "Electronic Music Night",
        category: "Music",
        location: "Club Neon",
        time: "Friday, 10:00 PM",
        attendingCount: 89,
        likesCount: 18,
        likesGoing: [
            EventProfile(name: "David", profileImage: "person.circle.fill")
        ]
    )
]

#Preview {
    EventsView()
}
