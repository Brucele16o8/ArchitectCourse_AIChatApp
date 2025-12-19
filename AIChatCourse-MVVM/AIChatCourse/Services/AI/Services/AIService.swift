//
//  AIService.swift
//  AIChatCourse
//
//  Created by Tung Le on 23/10/2025.
//
import SwiftUI

protocol AIService: Sendable {
    func generateImage(input: String) async throws -> UIImage
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel
}
