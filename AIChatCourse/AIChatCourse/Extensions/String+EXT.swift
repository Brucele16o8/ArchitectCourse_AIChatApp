//
//  String+EXT.swift
//  AIChatCourse
//
//  Created by Tung Le on 10/11/2025.
//
import Foundation

extension String {
    
    static func convertToString(_ value: Any) -> String? {
        switch value {
        case let value as String:
            return value
        case let value as Int:
            return String(value)
        case let value as Double:
            return String(value)
        case let value as Float:
            return String(value)
        case let value as Bool:
            return String(value)
        case let value as Date:
            return value.formatted(date: .abbreviated, time: .shortened)
        case let array as [Any]:
            return array.compactMap({ String.convertToString($0) }).sorted().joined(separator: ", ")
        case let value as CustomStringConvertible:
            return value.description
        default:
            return nil
        }
    }
    
} /// 🧱

extension String {
    
    func clipped(maxCharacter: Int) -> String {
        String(prefix(maxCharacter))
    }
    
    func replaceSpacesWithUnderscores() -> String {
        self.replacingOccurrences(of: " ", with: "_")
    }
    
} /// 🧱

extension String {
   var stableHashValue: Int {
        let unicodeScalars = self.unicodeScalars.map { $0.value }
        return unicodeScalars.reduce(5381) { ($0 << 5) &+ $0 &+ Int($1) }
    }
} /// 🧱
