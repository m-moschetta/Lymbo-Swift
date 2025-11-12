//
//  StorageService.swift
//  Lymbo
//
//  Created on 2025
//

import Foundation
import FirebaseStorage
import UIKit

actor UploadManager {
    private var activeUploads: Set<String> = []
    
    func startUpload(path: String) throws {
        if activeUploads.contains(path) {
            throw NSError(domain: "StorageService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Upload already in progress for this file"])
        }
        activeUploads.insert(path)
    }
    
    func finishUpload(path: String) {
        activeUploads.remove(path)
    }
}

final class StorageService: @unchecked Sendable {
    static let shared = StorageService()
    
    private let storage = Storage.storage()
    private let compressor = ImageCompressor.shared
    private let uploadManager = UploadManager()
    
    private init() {}
    
    // MARK: - Upload Image
    
    nonisolated func uploadImage(data: Data, path: String, contentType: String = "image/jpeg") async throws -> URL {
        let storageRef = storage.reference().child(path)
        
        let metadata = StorageMetadata()
        metadata.contentType = contentType
        
        _ = try await storageRef.putData(data, metadata: metadata)
        return try await storageRef.downloadURL()
    }
    
    // MARK: - Upload Profile Image (with compression)
    
    nonisolated func uploadProfileImage(image: UIImage, path: String) async throws -> URL {
        // Evita upload multipli simultanei dello stesso file
        try await uploadManager.startUpload(path: path)
        defer {
            Task {
                await uploadManager.finishUpload(path: path)
            }
        }
        
        // Log dimensione originale
        let originalData = image.jpegData(compressionQuality: 1.0)
        if let originalData = originalData {
            let originalSizeMB = Double(originalData.count) / (1024 * 1024)
            print("📤 Original profile image size: \(String(format: "%.2f", originalSizeMB)) MB (\(Int(image.size.width))x\(Int(image.size.height)))")
        }
        
        guard let compressedData = compressor.compressProfileImage(image) else {
            throw NSError(domain: "StorageService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to compress image"])
        }
        
        // Log della dimensione dopo compressione
        let compressedSizeMB = Double(compressedData.count) / (1024 * 1024)
        if let info = compressor.getImageSizeInfo(compressedData) {
            print("📸 Profile image compressed: \(String(format: "%.2f", compressedSizeMB)) MB (\(Int(info.width))x\(Int(info.height)))")
        }
        
        let url = try await uploadImage(data: compressedData, path: path)
        
        // Log dell'URL per debug
        print("📤 Profile image uploaded to: \(url.absoluteString)")
        
        return url
    }
    
    // MARK: - Upload Portfolio Image (with compression)
    
    nonisolated func uploadPortfolioImage(image: UIImage, userID: String, imageIndex: Int) async throws -> URL {
        let path = "portfolios/\(userID)/image_\(imageIndex).jpg"
        
        // Evita upload multipli simultanei dello stesso file
        try await uploadManager.startUpload(path: path)
        defer {
            Task {
                await uploadManager.finishUpload(path: path)
            }
        }
        
        // Log dimensione originale
        let originalData = image.jpegData(compressionQuality: 1.0)
        if let originalData = originalData {
            let originalSizeMB = Double(originalData.count) / (1024 * 1024)
            print("📤 Original portfolio image \(imageIndex) size: \(String(format: "%.2f", originalSizeMB)) MB (\(Int(image.size.width))x\(Int(image.size.height)))")
        }
        
        guard let compressedData = compressor.compressPortfolioImage(image) else {
            throw NSError(domain: "StorageService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to compress image"])
        }
        
        // Log della dimensione dopo compressione
        let compressedSizeMB = Double(compressedData.count) / (1024 * 1024)
        if let info = compressor.getImageSizeInfo(compressedData) {
            print("🖼️ Portfolio image \(imageIndex) compressed: \(String(format: "%.2f", compressedSizeMB)) MB (\(Int(info.width))x\(Int(info.height)))")
        }
        
        return try await uploadImage(data: compressedData, path: path)
    }
    
    // MARK: - Upload Portfolio Image (legacy - for compatibility)
    
    nonisolated func uploadPortfolioImage(userID: String, imageData: Data, imageIndex: Int) async throws -> URL {
        let path = "portfolios/\(userID)/image_\(imageIndex).jpg"
        return try await uploadImage(data: imageData, path: path)
    }
    
    // MARK: - Delete Image
    
    nonisolated func deleteImage(path: String) async throws {
        let storageRef = storage.reference().child(path)
        try await storageRef.delete()
    }
    
    // MARK: - Download Image URL
    
    nonisolated func getImageURL(path: String) async throws -> URL {
        let storageRef = storage.reference().child(path)
        return try await storageRef.downloadURL()
    }
}

