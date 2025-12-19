//
//  AvatarManager.swift
//  AIChatCourse
//
//  Created by Tung Le on 24/10/2025.
//
import SwiftUI
import SwiftData

@MainActor
@Observable
class AvatarManager {
    
    private let local: LocalAvatarPersistence
    private let remote: RemoteAvatarService
    
    init(
        service: RemoteAvatarService,
        local: LocalAvatarPersistence = MockLocalAvatarPersistence()
    ) {
        self.remote = service
        self.local = local
    }
    
    // MARK: Helper - Methods
    /// 🧩
    func addRecentAvatar(avatar: AvatarModel) async throws {
        try local.addRecentAvatar(avatar: avatar)
        try await remote.incrementAvatarClickCount(avatarId: avatar.id)
    }
    
    func getRecentAvatars() throws -> [AvatarModel] {
        try local.getRecentAvatars()
    }
    
    func getAvatar(id: String) async throws -> AvatarModel {
        try await remote.getAvatar(id: id)
    }
    
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        try await remote.createAvatar(avatar: avatar, image: image)
    }
    
    func getFeaturedAvatar() async throws -> [AvatarModel] {
        try await remote.getFeaturedAvatar()
    }
    
    func getPopularAvatar() async throws -> [AvatarModel] {
        try await remote.getPopularAvatar()
    }
    
    func getAvatarForCategory(category: CharacterOption) async throws -> [AvatarModel] {
        try await remote.getAvatarForCategory(category: category)
    }
    
    func getAvatarsForAuthor(userId: String) async throws -> [AvatarModel] {
        try await remote.getAvatarsForAuthor(userId: userId)
    }
    
    func removeAuthorIdFromAvatar(avatarId: String) async throws {
        try await remote.removeAuthorIdFromAvatar(avatarId: avatarId)
    }
    
    func removeAuthorIdFromAllUserAvatars(userId: String) async throws {
        try await remote.removeAuthorIdFromAllUserAvatars(userId: userId)
    }
    
} // 🧱
