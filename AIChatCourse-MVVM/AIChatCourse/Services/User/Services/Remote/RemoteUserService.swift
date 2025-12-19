//
//  UserService.swift
//  AIChatCourse
//
//  Created by Tung Le on 19/10/2025.
//
import Foundation

protocol RemoteUserService: Sendable {
    func saveUser(user: UserModel) async throws
    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, Error>
    func deleteUser(userId: String) async throws
    func markOnboardingCOmpleted(userId: String, profileColorHex: String) async throws
} /// 🧱
