//
//  ImageCompressor.swift
//  Lymbo
//
//  Created on 2025
//

import UIKit
import Foundation

final class ImageCompressor: @unchecked Sendable {
    static let shared = ImageCompressor()
    
    private init() {}
    
    // MARK: - Compression Settings
    
    /// Dimensione massima per immagini profilo (larghezza o altezza)
    private let maxProfileImageSize: CGFloat = 800
    
    /// Dimensione massima per immagini portfolio (larghezza o altezza)
    private let maxPortfolioImageSize: CGFloat = 1200
    
    /// Qualità JPEG per immagini profilo
    private let profileImageQuality: CGFloat = 0.75
    
    /// Qualità JPEG per immagini portfolio
    private let portfolioImageQuality: CGFloat = 0.80
    
    /// Dimensione massima file in MB (dopo compressione)
    private let maxFileSizeMB: Double = 2.0
    
    // MARK: - Compress Profile Image
    
    /// Comprime e ridimensiona un'immagine per il profilo
    func compressProfileImage(_ image: UIImage) -> Data? {
        return compressImage(image, maxSize: maxProfileImageSize, quality: profileImageQuality)
    }
    
    // MARK: - Compress Portfolio Image
    
    /// Comprime e ridimensiona un'immagine per il portfolio
    func compressPortfolioImage(_ image: UIImage) -> Data? {
        return compressImage(image, maxSize: maxPortfolioImageSize, quality: portfolioImageQuality)
    }
    
    // MARK: - Generic Compression
    
    /// Comprime e ridimensiona un'immagine
    private func compressImage(_ image: UIImage, maxSize: CGFloat, quality: CGFloat) -> Data? {
        // Log dimensione originale
        let originalSize = image.size
        print("🔄 Compressing image: original size \(Int(originalSize.width))x\(Int(originalSize.height))")
        
        // Ridimensiona l'immagine se necessario
        let resizedImage = resizeImage(image, maxSize: maxSize)
        
        let resizedSize = resizedImage.size
        if resizedSize != originalSize {
            print("📏 Image resized to: \(Int(resizedSize.width))x\(Int(resizedSize.height))")
        }
        
        // Prova diverse qualità fino a raggiungere la dimensione massima
        var compressionQuality = quality
        var imageData = resizedImage.jpegData(compressionQuality: compressionQuality)
        let maxFileSizeBytes = maxFileSizeMB * 1024 * 1024
        
        // Se l'immagine è ancora troppo grande, riduci la qualità
        var attempts = 0
        while let data = imageData, Double(data.count) > maxFileSizeBytes && compressionQuality > 0.1 && attempts < 10 {
            compressionQuality -= 0.1
            imageData = resizedImage.jpegData(compressionQuality: compressionQuality)
            attempts += 1
            
            if let currentData = imageData {
                let currentSizeMB = Double(currentData.count) / (1024 * 1024)
                print("🔧 Compression attempt \(attempts): quality \(String(format: "%.2f", compressionQuality)), size \(String(format: "%.2f", currentSizeMB)) MB")
            }
        }
        
        if let finalData = imageData {
            let finalSizeMB = Double(finalData.count) / (1024 * 1024)
            print("✅ Final compressed size: \(String(format: "%.2f", finalSizeMB)) MB (quality: \(String(format: "%.2f", compressionQuality)))")
        } else {
            print("❌ Failed to compress image")
        }
        
        return imageData
    }
    
    // MARK: - Resize Image
    
    /// Ridimensiona un'immagine mantenendo le proporzioni
    private func resizeImage(_ image: UIImage, maxSize: CGFloat) -> UIImage {
        let size = image.size
        
        // Se l'immagine è già più piccola della dimensione massima, non ridimensionare
        if size.width <= maxSize && size.height <= maxSize {
            return image
        }
        
        // Calcola il nuovo size mantenendo le proporzioni
        let ratio = min(maxSize / size.width, maxSize / size.height)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        // Usa UIGraphicsImageRenderer per migliore qualità e performance
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        return resizedImage
    }
    
    // MARK: - Get Image Size Info
    
    /// Restituisce informazioni sulla dimensione dell'immagine
    func getImageSizeInfo(_ data: Data) -> (width: CGFloat, height: CGFloat, sizeMB: Double)? {
        guard let image = UIImage(data: data) else { return nil }
        let sizeMB = Double(data.count) / (1024 * 1024)
        return (image.size.width, image.size.height, sizeMB)
    }
}

