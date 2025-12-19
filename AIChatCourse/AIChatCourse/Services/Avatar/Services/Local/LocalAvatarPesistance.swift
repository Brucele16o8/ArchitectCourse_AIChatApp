//
//  LocalAvatarPersistence.swift
//  AIChatCourse
//
//  Created by Tung Le on 27/10/2025.
//
import Foundation

@MainActor
protocol LocalAvatarPersistence {
    func addRecentAvatar(avatar: AvatarModel) throws
    func getRecentAvatars() throws -> [AvatarModel]
}
