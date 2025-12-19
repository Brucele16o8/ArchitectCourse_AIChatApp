//
//  AvatarService.swift
//  AIChatCourse
//
//  Created by Tung Le on 27/10/2025.
//
import SwiftUI

protocol RemoteAvatarService: Sendable {
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws
    func getAvatar(id: String) async throws -> AvatarModel
    func getFeaturedAvatar() async throws -> [AvatarModel]
    func getPopularAvatar() async throws -> [AvatarModel]
    func getAvatarForCategory(category: CharacterOption) async throws -> [AvatarModel]
    func getAvatarsForAuthor(userId: String) async throws -> [AvatarModel]
    func incrementAvatarClickCount(avatarId: String) async throws
    func removeAuthorIdFromAvatar(avatarId: String) async throws
    func removeAuthorIdFromAllUserAvatars(userId: String) async throws
} // 🧱
