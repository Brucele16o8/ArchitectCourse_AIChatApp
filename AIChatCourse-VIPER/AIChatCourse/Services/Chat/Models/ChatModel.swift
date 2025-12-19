//
//  ChatModel.swift
//  AIChatCourse
//
//  Created by Tung Le on 13/10/2025.
//

import Foundation
import IdentifiableByString

// MARK: - ChatModel
struct ChatModel: Identifiable, Codable, Hashable, StringIdentifiable {
    let id: String
    let userId: String
    let avatarId: String
    let dateCreated: Date
    let dateModified: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case avatarId = "avatar_id"
        case dateCreated = "date_created"
        case dateModified = "date_modified"
    }
    
    static func chatId(userId: String, avatarId: String) -> String {
        "\(userId)_\(avatarId)"
    }
    
    static func new(userId: String, avatarId: String) -> Self {
        ChatModel(
            id: chatId(userId: userId, avatarId: avatarId),
            userId: userId,
            avatarId: avatarId,
            dateCreated: .now,
            dateModified: .now
        )
    }
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "chat_\(CodingKeys.id.rawValue)": id,
            "chat_\(CodingKeys.userId.rawValue)": userId,
            "chat_\(CodingKeys.avatarId.rawValue)": avatarId,
            "chat_\(CodingKeys.dateCreated.rawValue)": dateCreated,
            "chat_\(CodingKeys.dateModified.rawValue)": dateModified
        ]
        
        return dict.compactMapValues({ $0 })
    }
}

// MARK: Mock data
extension ChatModel {
    static var mock: Self {
        mocks[0]
    }
    
    static var mocks: [Self] {
        let now = Date()
        return [
            ChatModel(
                id: UUID().uuidString,
                userId: UserAuthInfo.mock().uid,
                avatarId: AvatarModel.mocks.randomElement()!.avatarId,
                dateCreated: now.addingTimeInterval(days: -3, hours: -2),
                dateModified: now.addingTimeInterval(days: -2)
            ),
            ChatModel(
                id: UUID().uuidString,
                userId: UserAuthInfo.mock().uid,
                avatarId: AvatarModel.mocks.randomElement()!.avatarId,
                dateCreated: now.addingTimeInterval(days: -7),
                dateModified: now.addingTimeInterval(days: -1, hours: -3)
            ),
            ChatModel(
                id: UUID().uuidString,
                userId: UserAuthInfo.mock().uid,
                avatarId: AvatarModel.mocks.randomElement()!.avatarId,
                dateCreated: now.addingTimeInterval(days: -10, hours: -6),
                dateModified: now.addingTimeInterval(days: -5, hours: -2)
            ),
            ChatModel(
                id: UUID().uuidString,
                userId: UserAuthInfo.mock().uid,
                avatarId: AvatarModel.mocks.randomElement()!.avatarId,
                dateCreated: now.addingTimeInterval(days: -15, hours: -8),
                dateModified: now.addingTimeInterval(days: -10)
            )
        ]
    }
    
} // 📀
