//
//  FileManager+EXT.swift
//  AIChatCourse
//
//  Created by Tung Le on 19/10/2025.
//
import Foundation

extension FileManager {
    
    static func saveDocument<T: Codable>(key: String, value: T?) throws {
        let data = try JSONEncoder().encode(value)
        let url = getDodumentUrl(for: key)
        try data.write(to: url)
    }
    
    static func getDocument<T: Codable>(key: String) throws -> T? {
        let url = getDodumentUrl(for: key)
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    private static func getDodumentUrl(for key: String) -> URL {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("\(key).txt")
    }
    
} // 🧱
