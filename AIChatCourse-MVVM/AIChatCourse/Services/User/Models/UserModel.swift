//
//  Untitled.swift
//  AIChatCourse
//
//  Created by Tung Le on 14/10/2025.
//

import Foundation
import SwiftUI
import IdentifiableByString

struct UserModel: Codable, StringIdentifiable {
    var id: String {
        userId
    }
    
    let userId: String
    let email: String?
    let isAnonymous: Bool?
    let creationDate: Date?
    let creationVersion: String?
    let lastSignInDate: Date?
    let didCompleteOnboarding: Bool?
    let profileColorHex: String?
    
    init(
        userId: String,
        email: String? = nil,
        isAnonymous: Bool? = nil,
        creationDate: Date? = nil,
        creationVersion: String? = nil,
        lastSignInDate: Date? = nil,
        didCompleteOnboarding: Bool? = nil,
        profileColorHex: String? = nil
    ) {
        self.userId = userId
        self.email = email
        self.isAnonymous = isAnonymous
        self.creationDate = creationDate
        self.creationVersion = creationVersion
        self.lastSignInDate = lastSignInDate
        self.didCompleteOnboarding = didCompleteOnboarding
        self.profileColorHex = profileColorHex
    }
    
    init(auth: UserAuthInfo, creationVersion: String?) {
        self.init(
            userId: auth.uid,
            email: auth.email,
            isAnonymous: auth.isAnonymous,
            creationDate: auth.creationDate,
            creationVersion: creationVersion,
            lastSignInDate: auth.lastSignInDate
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email
        case isAnonymous = "is_anonymous"
        case creationDate = "creation_date"
        case creationVersion = "creation_version"
        case lastSignInDate = "last_sign_in_date"
        case didCompleteOnboarding = "did_complete_onboarding"
        case profileColorHex = "profile_color_hex"
    }

    var profileColorCalculated: Color? {
        guard let profileColorHex else {
            return .accent
        }
        return Color(hex: profileColorHex)
    }
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "user_\(CodingKeys.userId.rawValue)": userId,
            "user_\(CodingKeys.email.rawValue)": email,
            "user_\(CodingKeys.isAnonymous.rawValue)": isAnonymous,
            "user_\(CodingKeys.creationDate.rawValue)": creationDate,
            "user_\(CodingKeys.creationVersion.rawValue)": creationVersion,
            "user_\(CodingKeys.lastSignInDate.rawValue)": lastSignInDate,
            "user_\(CodingKeys.didCompleteOnboarding.rawValue)": didCompleteOnboarding,
            "user_\(CodingKeys.profileColorHex.rawValue)": profileColorHex
        ]
        
        return dict.compactMapValues({ $0 })
    }

} // 📀

// MARK: - Mock data
extension UserModel {
    
    static var mock: Self {
        mocks[0]
    }
    
    static var mocks: [Self] {
        let now = Date()
        return [
            UserModel(
                userId: "user001",
                creationDate: now.addingTimeInterval(-86400 * 5), // 5 days ago
                didCompleteOnboarding: true,
                profileColorHex: "#4ECDC4"
            ),
            UserModel(
                userId: "user002",
                creationDate: now.addingTimeInterval(-86400 * 10), // 10 days ago
                didCompleteOnboarding: false,
                profileColorHex: "#FF6B6B"
            ),
            UserModel(
                userId: "user003",
                creationDate: now.addingTimeInterval(-86400 * 20), // 20 days ago
                didCompleteOnboarding: true,
                profileColorHex: "#556270"
            ),
            UserModel(
                userId: "user004",
                creationDate: now.addingTimeInterval(-3600 * 12), // 12 hours ago
                didCompleteOnboarding: false,
                profileColorHex: "#C7F464"
            )
        ]
    }
    
} /// 🧱
