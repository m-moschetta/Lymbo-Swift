//
//  MatchService.swift
//  Lymbo
//
//  Created on 2025
//

import Foundation
import FirebaseFirestore
import Combine

struct Match: Codable, Identifiable {
    @DocumentID var id: String?
    var user1ID: String
    var user2ID: String
    var matchedAt: Timestamp
    var lastMessageAt: Timestamp?
    var isActive: Bool
    
    func getOtherUserID(currentUserID: String) -> String {
        return user1ID == currentUserID ? user2ID : user1ID
    }
}

struct Like: Codable, Identifiable {
    @DocumentID var id: String?
    var fromUserID: String
    var toUserID: String
    var createdAt: Timestamp
    var isSuperLike: Bool
}

@MainActor
class MatchService: ObservableObject {
    static let shared = MatchService()
    
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Like User
    
    func likeUser(fromUserID: String, toUserID: String, isSuperLike: Bool = false) async throws {
        // Check if already liked
        let existingLike = try await db.collection("likes")
            .whereField("fromUserID", isEqualTo: fromUserID)
            .whereField("toUserID", isEqualTo: toUserID)
            .limit(to: 1)
            .getDocuments()
        
        if !existingLike.documents.isEmpty {
            return // Already liked
        }
        
        // Create like
        let like = Like(
            id: nil,
            fromUserID: fromUserID,
            toUserID: toUserID,
            createdAt: Timestamp(),
            isSuperLike: isSuperLike
        )
        
        try await db.collection("likes").addDocument(from: like)
        
        // Check for mutual like (match)
        let mutualLike = try await db.collection("likes")
            .whereField("fromUserID", isEqualTo: toUserID)
            .whereField("toUserID", isEqualTo: fromUserID)
            .limit(to: 1)
            .getDocuments()
        
        if !mutualLike.documents.isEmpty {
            // Create match
            try await createMatch(user1ID: fromUserID, user2ID: toUserID)
        }
    }
    
    // MARK: - Create Match
    
    private func createMatch(user1ID: String, user2ID: String) async throws {
        // Check if match already exists
        let existingMatch = try await db.collection("matches")
            .whereField("user1ID", in: [user1ID, user2ID])
            .whereField("user2ID", in: [user1ID, user2ID])
            .limit(to: 1)
            .getDocuments()
        
        if !existingMatch.documents.isEmpty {
            return // Match already exists
        }
        
        let match = Match(
            id: nil,
            user1ID: user1ID,
            user2ID: user2ID,
            matchedAt: Timestamp(),
            lastMessageAt: nil,
            isActive: true
        )
        
        try await db.collection("matches").addDocument(from: match)
    }
    
    // MARK: - Fetch Matches
    
    func fetchMatches(for userID: String) async throws -> [Match] {
        let snapshot = try await db.collection("matches")
            .whereField("isActive", isEqualTo: true)
            .whereFilter(
                Filter.orFilter([
                    Filter.whereField("user1ID", isEqualTo: userID),
                    Filter.whereField("user2ID", isEqualTo: userID)
                ])
            )
            .order(by: "matchedAt", descending: true)
            .getDocuments()
        
        return try snapshot.documents.compactMap { try $0.data(as: Match.self) }
    }
    
    // MARK: - Fetch Received Likes
    
    func fetchReceivedLikes(for userID: String) async throws -> [Like] {
        let snapshot = try await db.collection("likes")
            .whereField("toUserID", isEqualTo: userID)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        return try snapshot.documents.compactMap { try $0.data(as: Like.self) }
    }
    
    // MARK: - Fetch Sent Likes
    
    func fetchSentLikes(for userID: String) async throws -> [Like] {
        let snapshot = try await db.collection("likes")
            .whereField("fromUserID", isEqualTo: userID)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        return try snapshot.documents.compactMap { try $0.data(as: Like.self) }
    }
    
    // MARK: - Unmatch
    
    func unmatch(matchID: String) async throws {
        try await db.collection("matches").document(matchID).updateData([
            "isActive": false
        ])
    }
}

