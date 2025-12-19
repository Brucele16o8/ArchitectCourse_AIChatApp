//
//  AuthService.swift
//  AIChatCourse
//
//  Created by Tung Le on 16/10/2025.
//

import SwiftUI

protocol AuthService: Sendable {
    func addAuthenticatedUserListener(onListenerAttached: (any NSObjectProtocol) -> Void) -> AsyncStream<UserAuthInfo?>
    func removeAuthenticatedUserListener(listener: any NSObjectProtocol)
    func getAuthenticationUser() -> UserAuthInfo?
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func signOut() throws
    func deleteAccount() async throws
} /// 🧱
