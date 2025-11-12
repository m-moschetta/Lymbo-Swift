//
//  CachedAsyncImage.swift
//  Lymbo
//
//  Created on 2025
//

import SwiftUI
import FirebaseStorage

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let storagePath: String?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder
    @State private var image: UIImage?
    @State private var isLoading = true
    
    init(
        url: URL? = nil,
        storagePath: String? = nil,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.storagePath = storagePath
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if isLoading {
                placeholder()
            } else if let image = image {
                content(Image(uiImage: image))
            } else {
                placeholder()
            }
        }
        .task {
            await loadImage()
        }
        .onChange(of: url?.absoluteString) { _ in
            Task {
                await loadImage()
            }
        }
        .onChange(of: storagePath) { _ in
            Task {
                await loadImage()
            }
        }
    }
    
    private func loadImage() async {
        guard storagePath != nil || url != nil else {
            await MainActor.run {
                isLoading = false
                image = nil
            }
            return
        }
        
        // Debug: log dell'URL che stiamo cercando di caricare
        if let storagePath = storagePath {
            print("🖼️ Loading image from storage path: \(storagePath)")
        } else if let url = url {
            print("🖼️ Loading image from: \(url.absoluteString)")
        }
        
        let cacheKey = storagePath ?? url?.absoluteString ?? UUID().uuidString
        
        // Controlla la cache locale prima
        if let cachedImage = await ImageCache.shared.getImage(forKey: cacheKey) {
            print("✅ Image found in cache")
            await MainActor.run {
                self.image = cachedImage
                self.isLoading = false
            }
            return
        }
        
        do {
            let data: Data
            if let storagePath = storagePath {
                data = try await downloadViaFirebase(path: storagePath)
            } else if let url = url {
                data = try await fetchImageData(from: url)
            } else {
                throw ImageLoaderError.unknown
            }
            
            guard let loadedImage = UIImage(data: data) else {
                print("⚠️ Failed to create UIImage from data (size: \(data.count) bytes)")
                await MainActor.run {
                    isLoading = false
                    image = nil
                }
                return
            }
            
            print("✅ Image loaded successfully (\(data.count) bytes)")
            
            // Salva nella cache
            await ImageCache.shared.setImage(loadedImage, forKey: cacheKey)
            
            await MainActor.run {
                self.image = loadedImage
                self.isLoading = false
            }
        } catch {
            print("❌ Error loading image from \(url): \(error.localizedDescription)")
            await MainActor.run {
                isLoading = false
                image = nil
            }
        }
    }
    
    private func fetchImageData(from url: URL) async throws -> Data {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ImageLoaderError.invalidResponse
            }
            
            print("📊 HTTP Status: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 403, isFirebaseStorageURL(url) {
                print("⚠️ 403 from Firebase Storage URL, retrying via Storage SDK")
                return try await downloadViaFirebaseStorage(url: url)
            }
            
            guard httpResponse.statusCode == 200 else {
                throw ImageLoaderError.httpError(code: httpResponse.statusCode)
            }
            
            return data
        } catch {
            if isFirebaseStorageURL(url) {
                print("⚠️ URLSession failed for Firebase Storage URL, retrying via Storage SDK")
                return try await downloadViaFirebaseStorage(url: url)
            }
            throw error
        }
    }
    
    private func downloadViaFirebaseStorage(url: URL) async throws -> Data {
        let reference = Storage.storage().reference(forURL: url.absoluteString)
        return try await download(from: reference)
    }
    
    private func downloadViaFirebase(path: String) async throws -> Data {
        let reference = Storage.storage().reference(withPath: path)
        return try await download(from: reference)
    }
    
    private func download(from reference: StorageReference) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            reference.getData(maxSize: 10 * 1024 * 1024) { data, error in
                if let data = data {
                    continuation.resume(returning: data)
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: ImageLoaderError.unknown)
                }
            }
        }
    }
    
    private func isFirebaseStorageURL(_ url: URL) -> Bool {
        guard let host = url.host?.lowercased() else { return false }
        return host.contains("firebasestorage.googleapis.com") ||
               host.contains("firebasestorage.app") ||
               host.contains("appspot.com")
    }
}

enum ImageLoaderError: Error {
    case invalidResponse
    case httpError(code: Int)
    case unknown
}

// MARK: - Image Cache

actor ImageCache {
    static let shared = ImageCache()
    
    private var cache: [String: UIImage] = [:]
    private let maxCacheSize = 50 // Numero massimo di immagini in cache
    
    private init() {}
    
    func getImage(forKey key: String) -> UIImage? {
        return cache[key]
    }
    
    func setImage(_ image: UIImage, forKey key: String) {
        // Se la cache è piena, rimuovi l'elemento più vecchio
        if cache.count >= maxCacheSize {
            if let firstKey = cache.keys.first {
                cache.removeValue(forKey: firstKey)
            }
        }
        
        cache[key] = image
    }
    
    func removeImage(forKey key: String) {
        cache.removeValue(forKey: key)
    }
    
    func clearCache() {
        cache.removeAll()
    }
}

// MARK: - Convenience Initializers

extension CachedAsyncImage where Content == Image, Placeholder == Image {
    init(url: URL? = nil, storagePath: String? = nil) {
        self.url = url
        self.storagePath = storagePath
        self.content = { $0 }
        self.placeholder = { Image(systemName: "photo") }
    }
}
