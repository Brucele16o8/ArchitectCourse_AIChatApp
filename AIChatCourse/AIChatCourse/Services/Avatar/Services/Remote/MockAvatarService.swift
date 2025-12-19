//
//  MockAvatarService.swift
//  AIChatCourse
//
//  Created by Tung Le on 27/10/2025.
//
import SwiftUI

struct MockAvatarService: RemoteAvatarService {
    
    var avatars: [AvatarModel]
    let delay: Double
    let showError: Bool
    
    init(avatars: [AvatarModel] = AvatarModel.mocks, delay: Double = 0.0, showError: Bool = false) {
        self.avatars = avatars
        self.delay = delay
        self.showError = showError
    }
    
    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
    
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        try? await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func getAvatar(id: String) async throws -> AvatarModel {
        try? await Task.sleep(for: .seconds(delay))
        
        try tryShowError()
        guard let avatar = avatars.first(where: { $0.id == id }) else {
            throw URLError(.noPermissionsToReadFile)
        }
        
        return avatar
    }
    
    func getFeaturedAvatar() async throws -> [AvatarModel] {
        try? await Task.sleep(for: .seconds(delay))
        try tryShowError()
        return avatars.shuffled()
    }
    
    func getPopularAvatar() async throws -> [AvatarModel] {
        try? await Task.sleep(for: .seconds(delay))
        try tryShowError()
        return avatars.shuffled()
    }
    
    func getAvatarForCategory(category: CharacterOption) async throws -> [AvatarModel] {
        try? await Task.sleep(for: .seconds(delay))
        try tryShowError()
        return avatars.shuffled()
    }
    
    func getAvatarsForAuthor(userId: String) async throws -> [AvatarModel] {
        try? await Task.sleep(for: .seconds(delay))
        try tryShowError()
        return avatars.shuffled()
    }
    
    func incrementAvatarClickCount(avatarId: String) async throws {
        
    }
    
    func removeAuthorIdFromAvatar(avatarId: String) async throws {
        
    }
    
    func removeAuthorIdFromAllUserAvatars(userId: String) async throws {
        
    }
    
} // 🧱
