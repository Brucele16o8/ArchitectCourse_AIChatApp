//
//  FileManagerUserPersistent.swift
//  AIChatCourse
//
//  Created by Tung Le on 23/10/2025.
//
import Foundation

struct FileManagerUserPersistent: LocalUserPersistence {
    private let userDocumentKey = "current_user"
    
    func getCurrentUser() -> UserModel? {
        try? FileManager.getDocument(key: userDocumentKey)
    }
    
    func saveCurrentUser(user: UserModel?) throws {
        try FileManager.saveDocument(key: userDocumentKey, value: user)
    }
    
}
