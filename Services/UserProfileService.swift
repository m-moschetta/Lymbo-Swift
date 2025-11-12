//
//  UserProfileService.swift
//  Lymbo
//
//  Created on 2025
//

import Foundation
import FirebaseFirestore
import Combine

struct UserProfile: Codable, Identifiable {
    @DocumentID var id: String?
    var email: String
    var displayName: String
    var firstName: String?
    var lastName: String?
    var artistName: String?
    var dateOfBirth: Timestamp?
    var bio: String?
    var profileImageURL: String?
    var profileImagePath: String?
    var location: String?
    var profession: String?
    var portfolioURL: String?
    var portfolioURLs: [String]?
    var portfolioPaths: [String]?
    var hasCompletedOnboarding: Bool?
    var preferences: UserPreferences?
    var createdAt: Timestamp
    var updatedAt: Timestamp
    
    struct UserPreferences: Codable {
        var showProfile: Bool = true
        var notificationsEnabled: Bool = true
    }
}

@MainActor
final class UserProfileService: ObservableObject {
    static let shared = UserProfileService()
    
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Create User Profile
    
    func createUserProfile(uid: String, email: String, displayName: String) async throws {
        let profile = UserProfile(
            id: uid,
            email: email,
            displayName: displayName,
            bio: nil,
            profileImageURL: nil,
            profileImagePath: nil,
            location: nil,
            profession: nil,
            portfolioURL: nil,
            portfolioURLs: nil,
            portfolioPaths: nil,
            preferences: UserProfile.UserPreferences(),
            createdAt: Timestamp(),
            updatedAt: Timestamp()
        )
        
        try await db.collection("users").document(uid).setData(from: profile)
    }
    
    func createOrUpdateUserProfile(uid: String, email: String, displayName: String) async throws {
        let userRef = db.collection("users").document(uid)
        let document = try await userRef.getDocument()
        
        if document.exists {
            // Update existing profile
            try await userRef.updateData([
                "email": email,
                "displayName": displayName,
                "updatedAt": Timestamp()
            ])
        } else {
            // Create new profile
            try await createUserProfile(uid: uid, email: email, displayName: displayName)
        }
    }
    
    // MARK: - Fetch User Profile
    
    func fetchUserProfile(uid: String) async throws -> UserProfile? {
        let document = try await db.collection("users").document(uid).getDocument()
        return try document.data(as: UserProfile.self)
    }
    
    // MARK: - Update User Profile
    
    func updateUserProfile(uid: String, updates: [String: Any]) async throws {
        var updatedData = updates
        updatedData["updatedAt"] = Timestamp()
        
        try await db.collection("users").document(uid).updateData(updatedData)
    }
    
    // MARK: - Upload Profile Image
    
    nonisolated func uploadProfileImage(uid: String, imageData: Data) async throws -> String {
        let path = "profiles/\(uid)/profile.jpg"
        let downloadURL = try await StorageService.shared.uploadImage(
            data: imageData,
            path: path
        )
        
        // Update profile with image URL
        try await updateUserProfile(uid: uid, updates: [
            "profileImageURL": downloadURL.absoluteString,
            "profileImagePath": path
        ])
        
        return downloadURL.absoluteString
    }
    
    // MARK: - Search Users
    
    func searchUsers(query: String, limit: Int = 20) async throws -> [UserProfile] {
        let snapshot = try await db.collection("users")
            .whereField("displayName", isGreaterThanOrEqualTo: query)
            .whereField("displayName", isLessThan: query + "\u{f8ff}")
            .limit(to: limit)
            .getDocuments()
        
        return try snapshot.documents.compactMap { try $0.data(as: UserProfile.self) }
    }
}
