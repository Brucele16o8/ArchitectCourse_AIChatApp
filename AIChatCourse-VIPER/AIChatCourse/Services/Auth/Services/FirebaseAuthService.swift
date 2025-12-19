//
//  FirebaseAuthService.swift
//  AIChatCourse
//
//  Created by Tung Le on 15/10/2025.
//

import FirebaseAuth
import SwiftUI
import SignInAppleAsync

struct FirebaseAuthService: AuthService {
    
    /// 🧩
    func addAuthenticatedUserListener(onListenerAttached: (any NSObjectProtocol) -> Void) -> AsyncStream<UserAuthInfo?> {
        AsyncStream { continuation in
            let listener = Auth.auth().addStateDidChangeListener { _, currentUser in
                if let currentUser {
                    let user = UserAuthInfo(user: currentUser)
                    continuation.yield(user)
                } else {
                    continuation.yield(nil)
                }
            }
            onListenerAttached(listener)
        }
    }
    /// ----- Helper
    func removeAuthenticatedUserListener(listener: any NSObjectProtocol) {
        Auth.auth().removeStateDidChangeListener(listener)
    }
    
    /// 🧩
    func getAuthenticationUser() -> UserAuthInfo? {
        if let user = Auth.auth().currentUser {
            return UserAuthInfo(user: user)
        }
        return nil
    }
    
//    func signInAnonymously() async throws -> AuthDataResult {
    /// 🧩
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let result = try await Auth.auth().signInAnonymously()
        return result.asAuthInfo
    }
    
    /// 🧩
    func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let helper = SignInWithAppleHelper()
        let response = try await helper.signIn()
        
        let credential = OAuthProvider.credential(
            providerID: AuthProviderID.apple,
            idToken: response.token,
            rawNonce: response.nonce
        )
        
        /// Try to link to existing anonymous account
        if let user = Auth.auth().currentUser, user.isAnonymous {
            do {
                let result = try await user.link(with: credential)
                return result.asAuthInfo
            } catch let error as NSError {
                let authError = AuthErrorCode(rawValue: error.code)
                switch authError {
                case .providerAlreadyLinked, .credentialAlreadyInUse:
                    if let secondaryCredential = error.userInfo["FIRAuthErrorUserInfoUpdatedCredentialKey"] as? AuthCredential {
                        let result = try await Auth.auth().signIn(with: secondaryCredential)
                        return result.asAuthInfo
                    }
                default:
                    break
                }
            }

        }
        
        /// Otherwise sign in to new account
        let result = try await Auth.auth().signIn(with: credential)
        return result.asAuthInfo
    }
    
    /// 🧩
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    /// 🧩
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.userNotFound
        }
        
        do {
            try await user.delete()
        } catch let error as NSError {
            let authError = AuthErrorCode(rawValue: error.code)
            switch authError {
            case .requiresRecentLogin:
                /// Try to reauthenticate
                try await reauthenticate(error: error)
                
                /// Reauthenticate successful
                return try await user.delete()
            default:
                throw error
            }
        }
    }
    /// ----- Helper
    private func reauthenticate(error: Error) async throws {
        guard let user = Auth.auth().currentUser, let providerId = user.providerData.first?.providerID else {
            throw AuthError.userNotFound
        }
        
        switch providerId {
        case "apple.com":
            let result = try await signInApple()
            
            /// Check edge case if it's the same original acocunt --> Avoid case that they switch account when reauthenticating
            guard user.uid == result.user.uid else {
                throw AuthError.reauthAccountChanged
            }
            
        default:
            throw error
        }
    }
        
    // MARK: - Helper - Types
    enum AuthError: LocalizedError {
        case userNotFound
        case reauthAccountChanged
        
        var errorDescription: String? {
            switch self {
            case .userNotFound:
                return "Current authenticated user not found."
            case .reauthAccountChanged:
                return "Reauthenticated switched account. Please check your account."
            }
        }
    }
    
} // 🧱

// MARK: - Helper - EXT
extension AuthDataResult {
    
    var asAuthInfo: (user: UserAuthInfo, isNewUser: Bool) {
        let user = UserAuthInfo(user: user)
        let isNewUser = additionalUserInfo?.isNewUser ?? true
        
        return (user, isNewUser)
    }
    
} /// 🧱
