//
//  Error.swift
//  AIChatCourse
//
//  Created by Tung Le on 12/11/2025.
//
import Foundation

extension Error {
    
    var eventParameters: [String: Any] {
        [
            "error_description": localizedDescription
        ]
    }
    
} /// 🧱
