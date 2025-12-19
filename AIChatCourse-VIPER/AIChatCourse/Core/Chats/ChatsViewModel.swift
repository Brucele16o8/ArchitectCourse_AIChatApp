//
//  ChatsViewModel.swift
//  AIChatCourse
//
//  Created by Tung Le on 12/12/2025.
//
import SwiftUI
 
@MainActor
protocol ChatsInteractor {
    func trackEvent(event: LoggableEvent)
    func getRecentAvatars() throws -> [AvatarModel]
    func getAuthId() throws -> String
    func getAllChats(userId: String) async throws -> [ChatModel]
}

extension CoreInteractor: ChatsInteractor { }

@Observable
@MainActor
class ChatsViewModel {
    let interactor: ChatsInteractor
    
    private(set) var chats: [ChatModel] = []
    private(set) var isLoadingChats: Bool = true
    private(set) var recentAvatars: [AvatarModel] = []
    
    var path: [TabbarPathOption] = []
    
    init(interactor: ChatsInteractor) {
        self.interactor = interactor
    }
    
    // MARK: - Method
    func loadRecentAvatars() {
        interactor.trackEvent(event: Event.loadAvatarStart)
        
        do {
            recentAvatars = try interactor.getRecentAvatars()
            interactor.trackEvent(event: Event.loadAvatarSuccess(avatarCount: recentAvatars.count))

        } catch {
            interactor.trackEvent(event: Event.loadAvatarFail(error: error))
        }
    }
    
    func loadChats() async {
        interactor.trackEvent(event: Event.loadChatsStart)
        
        do {
            let uid = try interactor.getAuthId()
            chats = try await interactor.getAllChats(userId: uid)
                .sortedByKeyPath(keyPath: \.dateModified, ascending: false)
            interactor.trackEvent(event: Event.loadChatsSuccess(chatsCount: chats.count))

        } catch {
            interactor.trackEvent(event: Event.loadChatsFail(error: error))
        }
        
        isLoadingChats = false
    }
    
    func onChatPressed(chat: ChatModel) {
        path.append(.chat(avatarId: chat.avatarId, chat: chat))
        interactor.trackEvent(event: Event.chatPressed(chat: chat))
    }
    
    func onAavatarPressed(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
        interactor.trackEvent(event: Event.avatarPressed(avatar: avatar))
    }
    
    // MARK: - Events
    enum Event: LoggableEvent {
        case loadAvatarStart
        case loadAvatarSuccess(avatarCount: Int)
        case loadAvatarFail(error: Error)
        case loadChatsStart
        case loadChatsSuccess(chatsCount: Int)
        case loadChatsFail(error: Error)
        case chatPressed(chat: ChatModel)
        case avatarPressed(avatar: AvatarModel)
        
        var eventName: String {
            switch self {
            case .loadAvatarStart:          return "ChatsView_LoadAvatars_Start"
            case .loadAvatarSuccess:        return "ChatsView_LoadAvatars_Success"
            case .loadAvatarFail:           return "ChatsView_LoadAvatars_Fail"
            case .loadChatsStart:           return "ChatsView_LoadChats_Start"
            case .loadChatsSuccess:         return "ChatsView_LoadChats_Success"
            case .loadChatsFail:            return "ChatsView_LoadChats_Fail"
            case .chatPressed:              return "ChatsView_Chat_Pressed"
            case .avatarPressed:            return "ChatsView_Avatar_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .loadAvatarSuccess(avatarCount: let avatarCount):
                return [
                    "avatar_count": avatarCount
                ]
            case .loadChatsSuccess(chatsCount: let chatsCount):
                return [
                    "chats_count": chatsCount
                ]
            case .loadAvatarFail(error: let error), .loadChatsFail(error: let error):
                return error.eventParameters
            case .chatPressed(chat: let chat):
                return chat.eventParameters
            case .avatarPressed(avatar: let avatar):
                return avatar.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .loadChatsFail, .loadAvatarFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
    
}
