//
//  OnFirstAppearViewModifier.swift
//  AIChatCourse
//
//  Created by Tung Le on 16/11/2025.
//
import SwiftUI

struct OnFirstAppearViewModifier: ViewModifier {
    
    @State private var didAppear: Bool = false
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                guard !didAppear else { return }
                didAppear = true
                action()
            }
    }
    
} // 🧱

struct OnFirstTaskViewModifier: ViewModifier {
    
    @State private var didAppear: Bool = false
    let action: () async -> Void
    
    func body(content: Content) -> some View {
        content
            .task {
                guard !didAppear else { return }
                didAppear = true
                await action()
            }
    }
    
} // 🧱

extension View {
    func onFirstAppear(_ action: @escaping () -> Void) -> some View {
        modifier(OnFirstAppearViewModifier(action: action))
    }
    
    func onFirstTask(_ action: @escaping () -> Void) -> some View {
        modifier(OnFirstAppearViewModifier(action: action))
    }
    
} /// 🧩
