//
//  Array+exr.swift
//  AIChatCourse
//
//  Created by Tung Le on 3/11/2025.
//
import Foundation

extension Array {
    
    /// 🧩
    mutating func sortByKeyPath<T: Comparable>(keyPath: KeyPath<Element, T>, ascending: Bool = true) {
        self.sort { item1, item2 in
            let value1 = item1[keyPath: keyPath]
            let value2 = item2[keyPath: keyPath]
            return ascending ? (value1 < value2) : (value1 > value2)
        }
    }
    
    /// 🧩
    func sortedByKeyPath<T: Comparable>(keyPath: KeyPath<Element, T>, ascending: Bool = true) -> [Element] {
        self.sorted { item1, item2 in
            let value1 = item1[keyPath: keyPath]
            let value2 = item2[keyPath: keyPath]
            return ascending ? (value1 < value2) : (value1 > value2)
        }
    }
    
} // 🧱
