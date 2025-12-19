//
//  AIManager.swift
//  AIChatCourse
//
//  Created by Tung Le on 23/10/2025.
//
import SwiftUI

@MainActor
@Observable
class AIManager {
    
    private let service: AIService

    init(service: AIService) {
        self.service = service
    }
    
    // MARK: Helper - Methods
    /// 🧩
    func generateImage(input: String) async throws -> UIImage {
        try await service.generateImage(input: input)
    }
    
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel {
        try await service.generateText(chats: chats)
    }
    
} // 🧱
