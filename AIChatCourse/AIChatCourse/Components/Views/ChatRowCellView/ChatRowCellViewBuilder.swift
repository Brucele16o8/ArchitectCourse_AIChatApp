//
//  ChatRowCellViewBuilder.swift
//  AIChatCourse
//
//  Created by Tung Le on 13/10/2025.
//

import SwiftUI

struct ChatRowCellViewBuilder: View {
    
    var currentUserId: String? = ""
    var chat: ChatModel = .mock
    var getAvatar: () async -> AvatarModel?
    var getLastChatMessage: () async -> ChatMessageModel?
    
    @State private var avatar: AvatarModel?
    @State private var latsChatMessage: ChatMessageModel?
    
    @State private var didLoadAvatar: Bool = false
    @State private var didLoadChatMessage: Bool = false
    
    private var isLoading: Bool {
        if didLoadAvatar && didLoadChatMessage {
            return false
        }
        return true
    }
    
    private var hasNewChat: Bool {
        guard let latsChatMessage, let currentUserId else { return false }
        return !latsChatMessage.hasBeenSeenBy(userId: currentUserId)
    }
    
    private var subheadline: String? {
        if isLoading {
            return "xxxx xxxx xxxx xxxx"
        }
        
        if avatar == nil && latsChatMessage == nil {
            return "Error loading data."
        }
        
        return latsChatMessage?.content?.message
    }
    
    var body: some View {
        ChatRowCellView(
            imageName: avatar?.profileImageName,
            headline: isLoading ? "xxxx xxxx" : avatar?.name,
            subheadline: subheadline,
            hasNewChat: isLoading ? false : hasNewChat
        )
        .redacted(reason: isLoading ? .placeholder : [])
        .task {
            avatar = await getAvatar()
            didLoadAvatar = true
        }
        .task {
            latsChatMessage = await getLastChatMessage()
            didLoadChatMessage = true
        }
    }
    
    // MARK: - Helper Methods
    
} // 🧱

#Preview {
    VStack {
        ChatRowCellViewBuilder(
            chat: ChatModel.mock,
            getAvatar: {
                try? await Task.sleep(for: .seconds(5))
                return AvatarModel.mock
            },
            getLastChatMessage: {
                try? await Task.sleep(for: .seconds(5))
                return ChatMessageModel.mock
            }
        )
        
        ChatRowCellViewBuilder(
            chat: ChatModel.mock,
            getAvatar: {
                AvatarModel.mock
            },
            getLastChatMessage: {
                ChatMessageModel.mock
            }
        )
        
        ChatRowCellViewBuilder(
            chat: ChatModel.mock,
            getAvatar: {
                nil
            },
            getLastChatMessage: {
                nil
            }
        )
        
        ChatRowCellViewBuilder(
            chat: ChatModel.mock,
            getAvatar: {
                nil
            },
            getLastChatMessage: {
                ChatMessageModel.mock
            }
        )
        
        ChatRowCellViewBuilder(
            chat: ChatModel.mock,
            getAvatar: {
                AvatarModel.mock
            },
            getLastChatMessage: {
                nil
            }
        )
    }
}
