//
//  FireBaseUserService.swift
//  AIChatCourse
//
//  Created by Tung Le on 19/10/2025.
//

import FirebaseFirestore
import SwiftfulFirestore

struct FireBaseUserService: RemoteUserService {
    
    var collection: CollectionReference {
        Firestore.firestore().collection("users")
    }
    
    func saveUser(user: UserModel) async throws {
        try collection.document(user.userId).setData(from: user, merge: true)
//        try await collection.setDocument(document: user) /// convinient way using SwiftfulFirestore package
    }
    
    func markOnboardingCOmpleted(userId: String, profileColorHex: String) async throws {
        try await collection.document(userId).updateData([
            UserModel.CodingKeys.didCompleteOnboarding.rawValue: true,
            UserModel.CodingKeys.profileColorHex.rawValue: profileColorHex
        ])
    }
    
    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, Error> {
        collection.streamDocument(id: userId)
    }
    
    func deleteUser(userId: String) async throws {
        try await collection.document(userId).delete()
//        try await collection.deleteDocument(id: userId) /// convinient way using SwiftfulFirestore package
    }
    
} // 🧱
