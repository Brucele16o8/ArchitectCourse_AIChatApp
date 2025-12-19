//
//  Dict+EXT.swift
//  AIChatCourse
//
//  Created by Tung Le on 8/11/2025.
//
import Foundation

extension Dictionary where Key == String, Value == Any {
    var asAlphabeticallyArray: [(key: Key, value: Value)] {
        self.map({ (key: $0, value: $1) }).sortedByKeyPath(keyPath: \.key)
    }
} /// 🧱

extension Dictionary {
    mutating func first(upTo maxItems: Int) {
        var counter: Int = 0
        for (key, _) in self {
            if counter >= maxItems {
                removeValue(forKey: key)
            } else {
                counter += 1
            }
        }
    }
} /// 🧱

extension Dictionary {
    
    mutating func merge(_ other: Dictionary?, conflictTakeExisting: Bool = true) {
        if let other {
            self.merge(other, uniquingKeysWith: { (existing, new) in
                return conflictTakeExisting ? existing : new
            })
        }
    }
    
} /// 🧱
