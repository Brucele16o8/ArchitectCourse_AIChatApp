//
//  Binding+EXT.swift
//  AIChatCourse
//
//  Created by Tung Le on 15/10/2025.
//
import SwiftUI
import Foundation

extension Binding where Value == Bool {
    
    init<T: Sendable>(ifNotNil value: Binding<T?>) {
        self.init {
            value.wrappedValue != nil
        } set: { newValue in
            if !newValue {
                value.wrappedValue = nil
            }
        }
    }

} /// 🧱
