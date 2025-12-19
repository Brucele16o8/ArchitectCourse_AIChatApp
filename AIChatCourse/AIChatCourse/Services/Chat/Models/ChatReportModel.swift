//
//  ChatReportModel.swift
//  AIChatCourse
//
//  Created by Tung Le on 4/11/2025.
//
import IdentifiableByString
import SwiftUI

struct ChatReportModel: Codable, StringIdentifiable {
    let id: String
    let chatId: String
    let userId: String /// reporting user
    let isActive: Bool
    let dataCreated: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case chatId = "chat_id"
        case userId = "user_id"
        case isActive = "is_active"
        case dataCreated = "date_created"
    }
    
    static func new(chatId: String, userId: String) -> Self {
        ChatReportModel(
            id: UUID().uuidString,
            chatId: chatId,
            userId: userId,
            isActive: true,
            dataCreated: .now
        )
    }
} /// 🧱
