//
//  TextValidationHelper.swift
//  AIChatCourse
//
//  Created by Tung Le on 14/10/2025.
//
import Foundation

struct TextValidationHelper {
    // MARK: - Helper Func
    /// 🧩
    static func checkIfTextIsValid(text: String, minimumCharacterCount: Int = 4) throws {
        guard text.count >= minimumCharacterCount else {
            throw TextValidationError.notEnoughCharacter(min: minimumCharacterCount)
        }
        
        let badWords: [String] = [
            "shit", "bitch", "ass"
        ]
        
        if badWords.contains(text.lowercased()) {
            throw TextValidationError.hasBadWords
        }
    }
    
    // MARK: - Helper Types
    enum TextValidationError: LocalizedError {
        case notEnoughCharacter(min: Int)
        case hasBadWords
        
        var errorDescription: String? {
            switch self {
            case .notEnoughCharacter(let min):
                return "Please add at least \(min) characters."
            case .hasBadWords:
                return "Bad word detected. Please rephrase your message."
            }
        }
    }

} // 🧱
