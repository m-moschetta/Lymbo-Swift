//
//  MainTabView.swift
//  Lymbo
//
//  Created on 2025
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ConnectView()
                .tabItem {
                    Label("Connect", systemImage: "person.2.fill")
                }
                .tag(0)
            
            LinksView()
                .tabItem {
                    Label("Links", systemImage: "link")
                }
                .tag(1)
            
            EventsView()
                .tabItem {
                    Label("Events", systemImage: "calendar")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
        .accentColor(.primaryColor)
    }
}

#Preview {
    MainTabView()
}

