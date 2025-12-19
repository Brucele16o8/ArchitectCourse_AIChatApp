//
//  CategoryRowTestOption.swift
//  AIChatCourse
//
//  Created by Tung Le on 25/11/2025.
//
import SwiftUI

enum CategoryRowTestOption: String, Codable, CaseIterable {
    case original, top, hidden
    
    static var `default`: Self {
        .original
    }
}
