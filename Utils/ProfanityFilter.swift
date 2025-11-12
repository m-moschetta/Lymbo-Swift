//
//  ProfanityFilter.swift
//  Lymbo
//
//  Created on 2025
//

import Foundation

final class ProfanityFilter: @unchecked Sendable {
    static let shared = ProfanityFilter()
    
    // Lista base di parolacce (in produzione usa una lista più completa)
    private let profanityWords: Set<String> = [
        "badword", "swear", "curse"
        // Aggiungi altre parole qui
    ]
    
    private init() {}
    
    func containsProfanity(_ text: String) -> Bool {
        let lowercased = text.lowercased()
        let words = lowercased.components(separatedBy: CharacterSet.alphanumerics.inverted)
        
        for word in words {
            if profanityWords.contains(word) {
                return true
            }
        }
        
        return false
    }
    
    func filterProfanity(_ text: String) -> String {
        var filtered = text
        let words = text.components(separatedBy: CharacterSet.alphanumerics.inverted)
        
        for word in words {
            if profanityWords.contains(word.lowercased()) {
                filtered = filtered.replacingOccurrences(of: word, with: String(repeating: "*", count: word.count), options: .caseInsensitive)
            }
        }
        
        return filtered
    }
}

