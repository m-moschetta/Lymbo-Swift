//
//  PhoneAuthService.swift
//  Lymbo
//
//  Created on 2025
//

import Foundation
import FirebaseAuth

@MainActor
class PhoneAuthService: ObservableObject {
    @Published var verificationID: String?
    @Published var errorMessage: String?
    
    func sendVerificationCode(phoneNumber: String) async throws {
        let phoneNumberWithPlus = phoneNumber.hasPrefix("+") ? phoneNumber : "+\(phoneNumber)"
        
        do {
            let verificationID = try await PhoneAuthProvider.provider().verifyPhoneNumber(
                phoneNumberWithPlus,
                uiDelegate: nil
            )
            self.verificationID = verificationID
        } catch {
            self.errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func verifyCode(_ code: String) async throws {
        guard let verificationID = verificationID else {
            throw NSError(domain: "PhoneAuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Verification ID not found"])
        }
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: code
        )
        
        _ = try await Auth.auth().signIn(with: credential)
    }
}

