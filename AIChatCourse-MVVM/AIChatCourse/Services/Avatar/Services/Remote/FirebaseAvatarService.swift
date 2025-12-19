//
//  FirebaseAvatarService.swift
//  AIChatCourse
//
//  Created by Tung Le on 27/10/2025.
//
import FirebaseFirestore
import SwiftfulFirestore

struct FirebaseAvatarService: RemoteAvatarService {
    
    var collection: CollectionReference {
        Firestore.firestore().collection("avatars")
    }
    
    /// 🧩
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        /// Upload the image
        let path = "avatars/\(avatar.avatarId)"
        let url = try await FirebaseImageUploadService().uploadImage(image: image, path: path)
        
        /// Update the avatar image name
        var avatar = avatar
        avatar.updateProfileImage(imageName: url.absoluteString)
        
        /// Upload the avatar
        try collection.document(avatar.avatarId).setData(from: avatar, merge: true)
    }
    
    /// 🧩
    func getAvatar(id: String) async throws -> AvatarModel {
        try await collection.getDocument(id: id)
    }
    
    /// 🧩
    func getFeaturedAvatar() async throws -> [AvatarModel] {
        try await collection
            .limit(to: 50)
            .getAllDocuments()
            .shuffled()
            .first(upTo: 8) ?? []
    }
    
    /// 🧩
    func getPopularAvatar() async throws -> [AvatarModel] {
        try await collection
            .order(by: AvatarModel.CodingKeys.clickCount.rawValue, descending: true)
            .limit(to: 200)
            .getAllDocuments()
    }
    
    /// 🧩
    func getAvatarForCategory(category: CharacterOption) async throws -> [AvatarModel] {
        try await collection
            .whereField(AvatarModel.CodingKeys.characterOption.rawValue, isEqualTo: category.rawValue)
            .limit(to: 200)
            .getAllDocuments()
    }
    
    /// 🧩
    func getAvatarsForAuthor(userId: String) async throws -> [AvatarModel] {
        try await collection
            .whereField(AvatarModel.CodingKeys.authorId.rawValue, isEqualTo: userId)
            .order(by: AvatarModel.CodingKeys.dateCreated.rawValue, descending: true) /// sorted on server
            .getAllDocuments()
//            .sorted(by: { ($0.dateCreated ?? .distantPast) > ($1.dateCreated ?? .distantPast)}) /// sorted on device
    }
    
    /// 🧩
    func removeAuthorIdFromAvatar(avatarId: String) async throws {
        try await collection.document(avatarId).updateData([
            AvatarModel.CodingKeys.authorId.rawValue: NSNull()
        ])
    }
    
    /// 🧩
    func removeAuthorIdFromAllUserAvatars(userId: String) async throws {
        let avatars = try await getAvatarsForAuthor(userId: userId)
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            for avatar in avatars {
                group.addTask {
                    try await removeAuthorIdFromAvatar(avatarId: avatar.id)
                }
            }
            
            try await group.waitForAll()
        }
    }
    
    /// 🧩
    func incrementAvatarClickCount(avatarId: String) async throws {
        try await collection.document(avatarId).updateData([
            AvatarModel.CodingKeys.clickCount.rawValue: FieldValue.increment(Int64(1))
        ])
    }
    
} // 🧱
