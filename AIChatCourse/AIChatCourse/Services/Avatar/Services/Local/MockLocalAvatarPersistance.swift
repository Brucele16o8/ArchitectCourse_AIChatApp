//
//  MockLocalAvatarPersistence.swift
//  AIChatCourse
//
//  Created by Tung Le on 27/10/2025.
//
import Foundation

struct MockLocalAvatarPersistence: LocalAvatarPersistence {
    
    let avatars: [AvatarModel]
    
    init(avatars: [AvatarModel] = AvatarModel.mocks) {
        self.avatars = avatars
    }
    
    func addRecentAvatar(avatar: AvatarModel) throws {
        
    }
    
    func getRecentAvatars() throws -> [AvatarModel] {
        avatars
    }
    
} // 🧱
