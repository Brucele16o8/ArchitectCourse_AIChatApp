//
//  ChatMessageModel.swift
//  AIChatCourse
//
//  Created by Tung Le on 13/10/2025.
//

import Foundation
import IdentifiableByString

struct ChatMessageModel: Identifiable, Codable, StringIdentifiable {
    let id: String
    let chatID: String
    let authorId: String?
    let content: AIChatModel?
    let seenByIds: [String]?
    let dateCreated: Date?
    
    init(
        id: String,
        chatID: String,
        authorId: String? = nil,
        content: AIChatModel? = nil,
        seenByIds: [String]? = nil,
        dateCreated: Date? = nil
    ) {
        self.id = id
        self.chatID = chatID
        self.authorId = authorId
        self.content = content
        self.seenByIds = seenByIds
        self.dateCreated = dateCreated
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case chatID = "chat_id"
        case authorId = "author_id"
        case content
        case seenByIds = "seen_by_ids"
        case dateCreated = "date_created"
    }
    
    var eventParameters: [String: Any] {
        var dict: [String: Any?] = [
            "message_\(CodingKeys.id.rawValue)": id,
            "message_\(CodingKeys.chatID.rawValue)": chatID,
            "message_\(CodingKeys.authorId.rawValue)": authorId,
            "message_\(CodingKeys.seenByIds.rawValue)": seenByIds?.sorted().joined(separator: ", "),
            "message_\(CodingKeys.dateCreated.rawValue)": dateCreated
        ]
        dict.merge(content?.eventParameters)
        
        return dict.compactMapValues({ $0 })
    }
    
    var dateCreatedCalculated: Date {
        dateCreated ?? .distantPast
    }
    
    static func newUserMessage(chatId: String, userId: String, message: AIChatModel) -> Self {
        ChatMessageModel(
            id: UUID().uuidString,
            chatID: chatId,
            authorId: userId,
            content: message,
            seenByIds: [userId],
            dateCreated: .now
        )
    }
    
    static func newAIMessage(chatId: String, avatarId: String, message: AIChatModel) -> Self {
        ChatMessageModel(
            id: UUID().uuidString,
            chatID: chatId,
            authorId: avatarId,
            content: message,
            seenByIds: [],
            dateCreated: .now
        )
    }

    func hasBeenSeenBy(userId: String) -> Bool {
        guard let seenByIds else { return false }
        return seenByIds.contains(userId)
    }
    
    static var mock: Self {
        mocks[0]
    }
    
    static var mocks: [Self] {
        let now = Date()
        return [
            ChatMessageModel(
                id: UUID().uuidString,
                chatID: "chat001",
                authorId: UserAuthInfo.mock().uid,
                content: AIChatModel(role: .user, content: "Hey there! How’s your day going?"),
                seenByIds: ["user002", "user003"],
                dateCreated: now.addingTimeInterval(days: -2, hours: -3)
            ),
            ChatMessageModel(
                id: UUID().uuidString,
                chatID: "chat001",
                authorId: AvatarModel.mock.avatarId,
                content: AIChatModel(role: .assistant, content: "Pretty good! Just finished work and relaxing now."),
                seenByIds: ["user001", "user003"],
                dateCreated: now.addingTimeInterval(days: -2, hours: -2, minutes: -30)
            ),
            ChatMessageModel(
                id: UUID().uuidString,
                chatID: "chat002",
                authorId: UserAuthInfo.mock().uid,
                content: AIChatModel(role: .user, content: "Don’t forget about tomorrow’s meeting!"),
                seenByIds: ["user001"],
                dateCreated: now.addingTimeInterval(days: -1, hours: -5)
            ),
            ChatMessageModel(
                id: UUID().uuidString,
                chatID: "chat002",
                authorId: AvatarModel.mock.avatarId,
                content: AIChatModel(role: .assistant, content: "Thanks for the reminder 😊 See you at 10am."),
                seenByIds: ["user003"],
                dateCreated: now.addingTimeInterval(days: -1, hours: -4, minutes: -45)
            )
        ]
    }

} // 📀
