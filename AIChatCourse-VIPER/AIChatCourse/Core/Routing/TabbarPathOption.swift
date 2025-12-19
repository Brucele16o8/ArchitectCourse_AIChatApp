//
//  NavigationPathOption.swift
//  AIChatCourse
//
//  Created by Tung Le on 15/10/2025.
//
import Foundation
import SwiftUI

enum TabbarPathOption: Hashable {
    case chat(avatarId: String, chat: ChatModel?)
    case category(category: CharacterOption, imageName: String)
}

struct NavDestinationForTabbarModuleModifier: ViewModifier {
    
    let path: Binding<[TabbarPathOption]>
    @ViewBuilder var chatView: (ChatViewDelegate) -> AnyView
    @ViewBuilder var categoryListView: (CategoryListDelegate) -> AnyView
    
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: TabbarPathOption.self) { newValue in
                switch newValue {
                case .chat(avatarId: let avatarId, chat: let chat):
                    chatView(
                        ChatViewDelegate(
                            chat: chat,
                            avatarId: avatarId
                        )
                    )
                    
                case .category(category: let category, imageName: let imageName):
                    categoryListView(
                        CategoryListDelegate(
                            path: path,
                            category: category,
                            imageName: imageName
                        )
                    )
                }
            }
    }
}

extension View {
    func navigationDestinationForTabbarModule(
        path: Binding<[TabbarPathOption]>,
        @ViewBuilder chatView: @escaping (ChatViewDelegate) -> AnyView,
        @ViewBuilder categoryListView: @escaping (CategoryListDelegate) -> AnyView
    ) -> some View {
        modifier(
            NavDestinationForTabbarModuleModifier(
                path: path,
                chatView: chatView,
                categoryListView: categoryListView
            )
        )
    }
}
