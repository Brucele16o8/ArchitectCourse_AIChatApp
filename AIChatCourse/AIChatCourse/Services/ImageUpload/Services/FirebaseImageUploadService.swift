//
//  FirebaseUpload.swift
//  AIChatCourse
//
//  Created by Tung Le on 25/10/2025.
//

@preconcurrency import FirebaseStorage
import SwiftUI

protocol ImageUploadService {
    func uploadImage(image: UIImage, path: String) async throws -> URL
}

struct FirebaseImageUploadService {
    
    func uploadImage(image: UIImage, path: String) async throws -> URL {
        guard let data = image.jpegData(compressionQuality: 1) else {
            throw URLError(.dataNotAllowed)
        }
        
        /// Upload Image
        _ = try await saveImage(data: data, path: path)
        
        /// Get download url
        return try await imageReference(path: path).downloadURL()
    }
    
    /// 🧩 /// causing concurrency issue -> using preconcurrency for import FirebaseStorage for now
    private func imageReference(path: String) -> StorageReference {
        let name = "\(path).jpg"
        return Storage.storage().reference(withPath: name)
    }
    
    /// 🧩
    private func saveImage(data: Data, path: String) async throws -> URL {
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"
        
        let returnedMeta = try await imageReference(path: path).putDataAsync(data, metadata: meta)
        
        guard let returnedPath = returnedMeta.path, let url = URL(string: returnedPath) else {
            throw URLError(.badServerResponse)
        }
        
        return url
    }
    
} // 🧱
