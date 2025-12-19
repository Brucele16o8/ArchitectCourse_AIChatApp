//
//  ChatService.swift
//  AIChatCourse
//
//  Created by Tung Le on 4/11/2025.
//
import Foundation

protocol ChatService: Sendable {
    func createNewChat(chat: ChatModel) async throws
    func getChat(userId: String, avatarId: String) async throws -> ChatModel?
    func getAllChats(userId: String) async throws -> [ChatModel]
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws
    func markChatMessageAsSeen(chatId: String, messageId: String, userId: String) async throws
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel?
    func streamChatMessage(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], Error>
    func deleteChat(chatId: String) async throws
    func deleteAllChatsForUser(userId: String) async throws
    func reportChat(report: ChatReportModel) async throws
}
