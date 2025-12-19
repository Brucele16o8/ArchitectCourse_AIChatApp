//
//  MockAuthService.swift
//  AIChatCourse
//
//  Created by Tung Le on 16/10/2025.
//
import Combine
import Foundation

class MockAuthService: AuthService {
    
    @Published var currentUser: UserAuthInfo?
    
    init(user: UserAuthInfo? = nil) {
        self.currentUser = user
    }

    func addAuthenticatedUserListener(onListenerAttached: (any NSObjectProtocol) -> Void) -> AsyncStream<UserAuthInfo?> {
        AsyncStream { continuation in
            continuation.yield(currentUser)
            
            Task {
                for await value in $currentUser.values {
                    continuation.yield(value)
                }
            }
        }
    }
    
    func removeAuthenticatedUserListener(listener: any NSObjectProtocol) {
        
    }
    
    func getAuthenticationUser() -> UserAuthInfo? {
        currentUser
    }
    
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let user = UserAuthInfo.mock(isAnonymous: true)
        currentUser = user
        return (user, true)
    }
    
    func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let user = UserAuthInfo.mock(isAnonymous: false)
        return (user, false)
    }
    
    func signOut() throws {
        
    }
    
    func deleteAccount() async throws {
        
    }
}
