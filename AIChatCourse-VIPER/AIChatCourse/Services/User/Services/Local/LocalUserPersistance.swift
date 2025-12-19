//
//  LocalUserPersistence.swift
//  AIChatCourse
//
//  Created by Tung Le on 23/10/2025.
//
import Foundation

protocol LocalUserPersistence {
    func getCurrentUser() -> UserModel?
    func saveCurrentUser(user: UserModel?) throws
}
