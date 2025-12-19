//
//  ChatManager.swift
//  AIChatCourse
//
//  Created by Tung Le on 1/11/2025.
//
import SwiftUI
import SwiftData

@MainActor
@Observable
class ChatManager {
    
    private let service: ChatService
    
    init(service: ChatService) {
        self.service = service
    }
    
    // MARK: Helper - Methods
    /// 🧩
    func createNewChat(chat: ChatModel) async throws {
        try await service.createNewChat(chat: chat)
    }
    
    /// 🧩
    func getChat(userId: String, avatarId: String) async throws -> ChatModel? {
        try await service.getChat(userId: userId, avatarId: avatarId)
    }
    
    /// 🧩
    func getAllChats(userId: String) async throws -> [ChatModel] {
        try await service.getAllChats(userId: userId)
    }
    
    /// 🧩
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws {
        try await service.addChatMessage(chatId: chatId, message: message)
    }
    
    /// 🧩
    func markChatMessageAsSeen(chatId: String, messageId: String, userId: String) async throws {
        try await service.markChatMessageAsSeen(chatId: chatId, messageId: messageId, userId: userId)
    }
    
    /// 🧩
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel? {
        try await service.getLastChatMessage(chatId: chatId)
    }
    
    /// 🧩
    func streamChatMessage(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], Error> {
        service.streamChatMessage(chatId: chatId)
    }
    
    /// 🧩
    func deleteChat(chatId: String) async throws {
        try await service.deleteChat(chatId: chatId)
    }
    
    /// 🧩
    func deleteAllChatsForUser(userId: String) async throws {
        try await service.deleteAllChatsForUser(userId: userId)
    }
    
    /// 🧩
    func reportChat(chatId: String, userId: String) async throws {
        let report = ChatReportModel.new(chatId: chatId, userId: userId)
        try await service.reportChat(report: report)
    }
    
} // 🧱
