//
//  ChatRowCellViewBuilder.swift
//  AIChatCourse
//
//  Created by Tung Le on 13/10/2025.
//

import SwiftUI

struct ChatRowCellViewBuilder: View {
    
    @State var viewModel: ChatRowCellViewModel
    var chat: ChatModel = .mock

    var body: some View {
        ChatRowCellView(
            imageName: viewModel.avatar?.profileImageName,
            headline: viewModel.isLoading ? "xxxx xxxx" : viewModel.avatar?.name,
            subheadline: viewModel.subheadline,
            hasNewChat: viewModel.isLoading ? false : viewModel.hasNewChat
        )
        .redacted(reason: viewModel.isLoading ? .placeholder : [])
        .task {
            await viewModel.loadAvatars(chat: chat)
        }
        .task {
            await viewModel.loadLastChatMessage(chat: chat)
        }
    }
    
} // 🧱

#Preview {
    VStack {
        ChatRowCellViewBuilder(
            viewModel: ChatRowCellViewModel(
                interactor: CoreInteractor(container: DevPreview.shared.container)
            ),
            chat: .mock
        )
        
        ChatRowCellViewBuilder(
            viewModel: ChatRowCellViewModel(
                interactor: AnyChatRowCellInteractor(
                    getAvatar: { _ in
                        try? await Task.sleep(for: .seconds(5))
                        return AvatarModel.mock
                    },
                    getLastChatMessage: { _ in
                        try? await Task.sleep(for: .seconds(5))
                        return ChatMessageModel.mock
                    }
                )
            ),
            chat: .mock
        )
        
        ChatRowCellViewBuilder(
            viewModel: ChatRowCellViewModel(
                interactor: AnyChatRowCellInteractor(
                    getAvatar: { _ in
                        AvatarModel.mock
                    },
                    getLastChatMessage: { _ in
                        ChatMessageModel.mock
                    }
                )
            ),
            chat: .mock
        )
        
        ChatRowCellViewBuilder(
            viewModel: ChatRowCellViewModel(
                interactor: AnyChatRowCellInteractor(
                    getAvatar: { _ in
                        throw URLError(.badServerResponse)
                    },
                    getLastChatMessage: { _ in
                        throw URLError(.badServerResponse)
                    }
                )
            ),
            chat: .mock
        )
    }
}
