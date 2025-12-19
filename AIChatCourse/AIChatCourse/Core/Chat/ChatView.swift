//
//  ChatView.swift
//  AIChatCourse
//
//  Created by Tung Le on 14/10/2025.
//

import SwiftUI

struct ChatView: View {
    @Environment(UserManager.self) private var userManager
    @Environment(AuthManager.self) private var authManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(ChatManager.self) private var chatManager
    @Environment(AIManager.self) private var aiManager
    @Environment(LogManager.self) private var logManager
    @Environment(PurchaseManager.self) private var purchaseManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var chatMessages: [ChatMessageModel] = []
    @State private var avatar: AvatarModel?
    @State private var currentUser: UserModel? = .mock
    @State var chat: ChatModel?
    
    @State private var textFieldText: String = ""
    @State private var scrollPosition: String?
    
    @State private var showAlert: AnyAppAlert?
    @State private var showChatSettings: AnyAppAlert?
    @State private var showProfileModal: Bool = false
    @State private var isGeneratingResponse: Bool = false
    @State private var showPaywall: Bool = false
    
    var avatarId: String = AvatarModel.mock.avatarId
    
    var body: some View {
        VStack(spacing: 0) {
            scrollViewSection
            textFieldSection
        }
        .navigationTitle(avatar?.name ?? "")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    if isGeneratingResponse {
                        ProgressView()
                    }
                    
                    Image(systemName: "ellipsis")
                        .padding(8)
                        .anyButton(.plain) {
                            onChatSettingPressed()
                        }
                }
            }
        }
        .screenAppearAnalytics(name: "ChatView")
        .showCustomAlert(type: .confirmationDiaglog, alert: $showChatSettings)
        .showCustomAlert(alert: $showAlert)
        .showModal(showModal: $showProfileModal) {
            if let avatar {
                profileModal(avatar: avatar)
            }
        }
        .sheet(isPresented: $showPaywall, content: {
            PayWallView()
        })
        .task {
            await loadAvatar()
        }
        .task {
            await loadChat()
            await listenForChatMessage()
        }
        .onAppear {
            loadCurrentUser()
        }
    }
    
    // MARK: - Helper Views
    private func timestampView(date: Date) -> some View {
        Group {
            Text(date.formatted(date: .long, time: .omitted))
            +
            Text(" • ")
            +
            Text(date.formatted(date: .omitted, time: .shortened))
        }
        .foregroundStyle(.secondary)
        .font(.callout)
        .lineLimit(1)
        .minimumScaleFactor(0.3)
    }
    
    private var scrollViewSection: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                ForEach(chatMessages) { message in
                    if messageIsDelayed(message: message) {
                        timestampView(date: message.dateCreatedCalculated)
                    }
                    
                    let isCurrentUser = message.authorId == authManager.auth?.uid
                    ChatBubbleViewBuilder(
                        message: message,
                        isCurrentUser: isCurrentUser,
                        currentUserProfileColor: currentUser?.profileColorCalculated ?? .accent,
                        imageName: isCurrentUser ? nil : avatar?.profileImageName,
                        onImagePressed: onAvatarImagePressed
                    )
                    .onAppear {
                        onMessageDidAppear(message: message)
                    }
                    .id(message.id)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(8)
            .rotationEffect(.degrees(180))
        }
        .rotationEffect(.degrees(180))
        .scrollPosition(id: $scrollPosition, anchor: .center)
        .animation(.default, value: chatMessages.count)
        .animation(.default, value: scrollPosition)
    }
    
    private var textFieldSection: some View {
        TextField("Say something...", text: $textFieldText)
            .keyboardType(.alphabet)
            .autocorrectionDisabled(true)
            .padding(12)
            .padding(.trailing, 60)
            .accessibilityIdentifier("ChatTextField")
            .overlay(
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .padding(.trailing, 4)
                    .foregroundStyle(.accent)
                    .anyButton(.plain, action: {
                        onSendMessagePressed()
                    })
                ,
                alignment: .trailing
            )
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 100)
                        .fill(Color(uiColor: .systemBackground))
                    
                    RoundedRectangle(cornerRadius: 100)
                        .stroke(Color.gray.opacity(0.3))
                }
            )
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(uiColor: .secondarySystemBackground))
    }
    
    private func profileModal(avatar: AvatarModel) -> some View {
        ProfileModalView(
            imageName: avatar.profileImageName,
            title: avatar.name,
            subtitle: avatar.characterOption?.rawValue.capitalized,
            headline: avatar.characterDescription,
            onXMarkPressed: {
                showProfileModal = false
            }
        )
        .padding(40)
        .transition(.slide)
    }
    
    // MARK: - Helper Types
    enum ChatViewError: Error {
        case noChat
    }
    
    // MARK: - Helper Func
    /// 🧩    
    private func onMessageDidAppear(message: ChatMessageModel) {
        Task {
            do {
                let uid = try authManager.getAuthId()
                let chatId = try getChatId()
                
                guard !message.hasBeenSeenBy(userId: uid) else {
                    return
                }
                
                try await chatManager.markChatMessageAsSeen(chatId: chatId, messageId: message.id, userId: uid)
            } catch {
                logManager.trackEvent(event: Event.messageSeenFail(error: error))
            }
        }
    }
    
    /// 🧩
    private func messageIsDelayed(message: ChatMessageModel) -> Bool {
        let currentMessageDate = message.dateCreatedCalculated
        
        guard
            let index = chatMessages.firstIndex(where: { $0.id == message.id }),
            chatMessages.indices.contains(index - 1)
        else {
            return false
        }
        
        let previousMessageDate = chatMessages[index - 1].dateCreatedCalculated
        let timeDiff = currentMessageDate.timeIntervalSince(previousMessageDate)
        
        /// Threshold = 60 seconds * 45 minutes
        let threshold: TimeInterval = 60 * 45
        
        return timeDiff > threshold
        
    }
    
    /// 🧩
    private func loadCurrentUser() {
        currentUser = userManager.currentUser
    }
    
    /// 🧩
    private func loadAvatar() async {
        logManager.trackEvent(event: Event.loadAvatarStart)
        
        do {
            let avatar = try await avatarManager.getAvatar(id: avatarId)
            logManager.trackEvent(event: Event.loadAvatarSuccess(avatar: avatar))
            
            self.avatar = avatar
            try? await avatarManager.addRecentAvatar(avatar: avatar)
        } catch {
            logManager.trackEvent(event: Event.loadAvatarFail(error: error))
        }
    }
    
    /// 🧩
    private func loadChat() async {
        logManager.trackEvent(event: Event.loadChatStart)
        
        do {
            let uid = try authManager.getAuthId()
            chat = try await chatManager.getChat(userId: uid, avatarId: avatarId)
            
            logManager.trackEvent(event: Event.loadChatSuccess(chat: chat))
        } catch {
            logManager.trackEvent(event: Event.loadChatFail(error: error))
        }
    }
    
    /// 🧩
    private func getChatId() throws -> String {
        guard let chat else {
            throw ChatViewError.noChat
        }
        return chat.id
    }
    
    private func listenForChatMessage() async {
        logManager.trackEvent(event: Event.loadMessagesStart)
        
        do {
            let chatId = try getChatId()
            
            for try await value in chatManager.streamChatMessage(chatId: chatId) {
                chatMessages = value
                    .sortedByKeyPath(keyPath: \.dateCreatedCalculated, ascending: true)
//                    .sorted(by: { $0.dateCreatedCalculated < $1.dateCreatedCalculated })
                scrollPosition = chatMessages.last?.id
            }
        } catch {
            logManager.trackEvent(event: Event.loadMessagesFail(error: error))
        }
    }
    
    /// 🧩
    private func onSendMessagePressed() {
        let content = textFieldText
        logManager.trackEvent(event: Event.sendMessageStart(chat: chat, avatar: avatar))
        
        Task {
            do {
                /// Show paywall if needed
                /// User is NOT premium
                /// Chat has >= 3 messages
                let isPremium = purchaseManager.entitlements.hasActiveEntitlement
                if !isPremium && chatMessages.count >= 3 {
                    showPaywall = true
                    return
                }
                
                /// Get userId
                let uid = try authManager.getAuthId()
                
                /// Validate textField text
                try TextValidationHelper.checkIfTextIsValid(text: content)
                
                /// If chat is new, then create a new chat
                if chat == nil {
                    chat = try await createNewChat(uid: uid)
                }
                
                /// If there is no chat, throw error (should never happen)
                guard let chat else {
                    throw ChatViewError.noChat
                }
                
                /// Create User chat
                let newChatMessage = AIChatModel(role: .user, content: content)
                let message = ChatMessageModel.newUserMessage(chatId: chat.id, userId: uid, message: newChatMessage)
                
                /// Upload User Chat
                try await chatManager.addChatMessage(chatId: chat.id, message: message)
                logManager.trackEvent(event: Event.sendMessageSent(chat: chat, avatar: avatar, message: message))
                textFieldText = ""
                            
                /// Generate AI Response
                isGeneratingResponse = true
                var aiChats = chatMessages.compactMap { $0.content }
                if let avatarDescription = avatar?.characterDescription {
                    /// "A cat that is smiling in the park"
                    let systemMessage = AIChatModel(
                        role: .system,
                        content: "You are \(avatarDescription) with the intelligence of an AI. We are having a VERY casual conversation. You are my friend."
                    )
                    aiChats.insert(systemMessage, at: 0)
                }
                
                let response = try await aiManager.generateText(chats: aiChats)
                
                /// Create AI Chat
                let newAIMessage = ChatMessageModel.newAIMessage(chatId: chat.id, avatarId: avatarId, message: response)
                logManager.trackEvent(event: Event.sendMessageResponse(chat: chat, avatar: avatar, message: newAIMessage))

                /// Upload AI chat
                try await chatManager.addChatMessage(chatId: chat.id, message: newAIMessage)
                logManager.trackEvent(event: Event.sendMessageResponseSent(chat: chat, avatar: avatar, message: newAIMessage))
    
            } catch let error {
                showAlert = AnyAppAlert(error: error)
                logManager.trackEvent(event: Event.sendMessageFail(error: error))
            }
            
            isGeneratingResponse = false
        }
    }
    
    /// 🧩
    private func createNewChat(uid: String) async throws -> ChatModel {
        logManager.trackEvent(event: Event.createChatStart)
        let newChat = ChatModel.new(userId: uid, avatarId: avatarId)
        try await chatManager.createNewChat(chat: newChat)
        
        defer {
            Task {
                await listenForChatMessage()
            }
        }
        
        return newChat
    }
    
    /// 🧩
    private func onChatSettingPressed() {
        logManager.trackEvent(event: Event.chatSettingPressed)
        
        showChatSettings = AnyAppAlert(
            title: "",
            subtitle: "What would you like to do?",
            buttons: {
                AnyView(
                    Group {
                        Button("Report User / Chat", role: .destructive) {
                            onReportChatPressed()
                        }
                        Button("Delete Chat", role: .destructive) {
                            onDeleteChatPressed()
                        }
                    }
                )
            }
        )
    }
    
    /// 🧩
    private func onReportChatPressed() {
        logManager.trackEvent(event: Event.reportChatStart)

        Task {
            do {
                let uid = try authManager.getAuthId()
                let chatId = try getChatId()
                try await chatManager.reportChat(chatId: chatId, userId: uid)
                logManager.trackEvent(event: Event.reportChatSuccess)
                
                showAlert = AnyAppAlert(
                    title: "🚨 Reported 🚨",
                    subtitle: "We will review the chat shortly. You may leave the chat at any time. Thanks for bringing this to our attention!",
                )
            } catch {
                logManager.trackEvent(event: Event.reportChatFail(error: error))
                showAlert = AnyAppAlert(
                    title: "Something went wrong.",
                    subtitle: "Please check your internet connection and try again.",
                )
            }
        }
    }

    /// 🧩
    private func onDeleteChatPressed() {
        logManager.trackEvent(event: Event.deleteChatStart)
        
        Task {
            do {
                let chatId = try getChatId()
                try await chatManager.deleteChat(chatId: chatId)
                logManager.trackEvent(event: Event.deleteChatSuccess)
                
                dismiss()
            } catch {
                logManager.trackEvent(event: Event.deleteChatFail(error: error))
                showAlert = AnyAppAlert(
                    title: "Something went wrong.",
                    subtitle: "Please check your internet connection and try again.",
                )
            }
        }
    }
    
    /// 🧩
    private func onAvatarImagePressed() {
        logManager.trackEvent(event: Event.avatarImagePressed(avatar: avatar))

        showProfileModal = true
    }
    
    // MARK: Helper - Types
    enum Event: LoggableEvent {
        case loadAvatarStart
        case loadAvatarSuccess(avatar: AvatarModel?)
        case loadAvatarFail(error: Error)
        case loadChatStart
        case loadChatSuccess(chat: ChatModel?)
        case loadChatFail(error: Error)
        case loadMessagesStart
        case loadMessagesFail(error: Error)
        case messageSeenFail(error: Error)
        case sendMessageStart(chat: ChatModel?, avatar: AvatarModel?)
        case sendMessagePaywall(chat: ChatModel?, avatar: AvatarModel?)
        case sendMessageFail(error: Error)
        case sendMessageSent(chat: ChatModel?, avatar: AvatarModel?, message: ChatMessageModel)
        case sendMessageResponse(chat: ChatModel?, avatar: AvatarModel?, message: ChatMessageModel)
        case sendMessageResponseSent(chat: ChatModel?, avatar: AvatarModel?, message: ChatMessageModel)
        case createChatStart
        case chatSettingPressed
        case reportChatStart
        case reportChatSuccess
        case reportChatFail(error: Error)
        case deleteChatStart
        case deleteChatSuccess
        case deleteChatFail(error: Error)
        case avatarImagePressed(avatar: AvatarModel?)
        
        var eventName: String {
            switch self {
            case .loadAvatarStart:            return "ChatView_LoadAvatar_Start"
            case .loadAvatarSuccess:          return "ChatView_LoadAvatar_Success"
            case .loadAvatarFail:             return "ChatView_LoadAvatar_Fail"
            case .loadChatStart:              return "ChatView_LoadChat_Start"
            case .loadChatSuccess:            return "ChatView_LoadChat_Success"
            case .loadChatFail:               return "ChatView_LoadChat_Fail"
            case .loadMessagesStart:          return "ChatView_LoadMessages_Start"
            case .loadMessagesFail:           return "ChatView_LoadMessages_Fail"
            case .messageSeenFail:            return "ChatView_MessageSeen_Fail"
            case .sendMessageStart:           return "ChatView_SendMessage_Start"
            case .sendMessagePaywall:         return "ChatView_SendMessage_Paywall"
            case .sendMessageFail:            return "ChatView_SendMessage_Fail"
            case .sendMessageSent:            return "ChatView_SendMessage_Sent"
            case .sendMessageResponse:        return "ChatView_SendMessage_Response"
            case .sendMessageResponseSent:    return "ChatView_SendMessage_ResponseSent"
            case .createChatStart:            return "ChatView_CreateChat_Start"
            case .chatSettingPressed:         return "ChatView_ChatSettings_Pressed"
            case .reportChatStart:            return "ChatView_ReportChat_Start"
            case .reportChatSuccess:          return "ChatView_ReportChat_Success"
            case .reportChatFail:             return "ChatView_ReportChat_Fail"
            case .deleteChatStart:            return "ChatView_DeleteChat_Start"
            case .deleteChatSuccess:          return "ChatView_DeleteChat_Success"
            case .deleteChatFail:             return "ChatView_DeleteChat_Fail"
            case .avatarImagePressed:         return "ChatView_AvatarImage_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .loadAvatarFail(error: let error), .loadChatFail(error: let error), .loadMessagesFail(error: let error), .messageSeenFail(error: let error), .sendMessageFail(error: let error), .reportChatFail(error: let error), .deleteChatFail(error: let error):
                return error.eventParameters
            case .loadAvatarSuccess(avatar: let avatar), .avatarImagePressed(avatar: let avatar):
                return avatar?.eventParameters
            case .loadChatSuccess(chat: let chat):
                return chat?.eventParameters
            case .sendMessageStart(chat: let chat, avatar: let avatar), .sendMessagePaywall(chat: let chat, avatar: let avatar):
                var dict = chat?.eventParameters ?? [:]
                dict.merge(avatar?.eventParameters)
                return dict
            case .sendMessageSent(chat: let chat, avatar: let avatar, message: let message), .sendMessageResponse(chat: let chat, avatar: let avatar, message: let message), .sendMessageResponseSent(chat: let chat, avatar: let avatar, message: let message):
                var dict = chat?.eventParameters ?? [:]
                dict.merge(avatar?.eventParameters)
                dict.merge(message.eventParameters)
                return dict
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .loadChatFail, .sendMessageFail, .loadMessagesFail:
                return .warning
            case .loadAvatarFail, .messageSeenFail, .reportChatFail, .deleteChatFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
    
} // 🧱

#Preview("Working chat - Not premium") {
    NavigationStack {
        ChatView()
            .previewEnvironment()
    }
}

#Preview("Working chat - Premium") {
    NavigationStack {
        ChatView()
            .environment(PurchaseManager(service: MockPurchaseService(activeEntitlements: [.mock])))
            .previewEnvironment()
    }
}

#Preview("Slow AI Generation") {
    NavigationStack {
        ChatView()
            .environment(AIManager(service: MockAIService(delay: 10.0)))
            .previewEnvironment()
    }
}

#Preview("Failed AI Generation") {
    NavigationStack {
        ChatView()
            .environment(AIManager(service: MockAIService(delay: 2.0, showError: true)))
            .previewEnvironment()
    }
}
