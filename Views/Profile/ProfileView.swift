//
//  ProfileView.swift
//  Lymbo
//
//  Created on 2025
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        // Profile Image
                        Button(action: {
                            // Show full image
                        }) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 100))
                                .foregroundColor(.foreground)
                                .frame(width: 120, height: 120)
                                .background(Color.muted)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.border, lineWidth: 2)
                                )
                        }
                        
                        VStack(spacing: 8) {
                            Text("Your Name")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.foreground)
                            
                            Text("Update your profile to stand out")
                                .font(.system(size: 16))
                                .foregroundColor(.mutedForeground)
                        }
                        
                        // My Badge Button
                        Button(action: {
                            // Show badge
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
                                action: {}
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
                .padding(.bottom, 40)
            }
            .background(Color.backgroundColor)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
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

