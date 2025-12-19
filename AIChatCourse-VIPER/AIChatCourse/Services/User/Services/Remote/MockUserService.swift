//
//  MockUserService.swift
//  AIChatCourse
//
//  Created by Tung Le on 19/10/2025.
//
import Combine
import Foundation

class MockUserService: RemoteUserService {
    
    @Published var currentUser: UserModel?
    
    init(user: UserModel? = nil) {
        self.currentUser = user
    }
    
    func saveUser(user: UserModel) async throws {
        currentUser = user
    }
    
    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, any Error> {
        AsyncThrowingStream { continuation in
            if let currentUser {
                continuation.yield(currentUser)
            }
            
            Task {
                for await value in $currentUser.values {
                    if let value {
                        continuation.yield(value)
                    }
                }
            }
        }
    }
    
    func deleteUser(userId: String) async throws {
        currentUser = nil
    }
    
    func markOnboardingCOmpleted(userId: String, profileColorHex: String) async throws {
        guard let currentUser else {
            throw URLError(.unknown)
        }
        
        self.currentUser = UserModel(
            userId: currentUser.userId,
            email: currentUser.email,
            isAnonymous: currentUser.isAnonymous,
            creationDate: currentUser.creationDate,
            creationVersion: currentUser.creationVersion,
            lastSignInDate: currentUser.lastSignInDate,
            didCompleteOnboarding: true,
            profileColorHex: profileColorHex
        )
    }
    
} // 🧱
