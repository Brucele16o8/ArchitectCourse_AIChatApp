//
//  CategoryListViewModel.swift
//  AIChatCourse
//
//  Created by Tung Le on 13/12/2025.
//
import SwiftUI

@MainActor
protocol CategoryListInteractor {
    func trackEvent(event: LoggableEvent)
    func getAvatarForCategory(category: CharacterOption) async throws -> [AvatarModel]
}

extension CoreInteractor: CategoryListInteractor { }

@Observable
@MainActor
class CategoryListViewModel {
    let interactor: CategoryListInteractor
    
    private(set) var avatars: [AvatarModel] = []
    private(set) var isLoading: Bool = true
    
    var showAlert: AnyAppAlert?
    
    init(interactor: CategoryListInteractor) {
        self.interactor = interactor
    }
    
    // MARK: - Methods
    func loadAvatars(category: CharacterOption) async {
        interactor.trackEvent(event: Event.loadAvatarsStart)
        do {
            avatars = try await interactor.getAvatarForCategory(category: category)
            interactor.trackEvent(event: Event.loadAvatarsSuccess)
        } catch {
            showAlert = AnyAppAlert(error: error)
            interactor.trackEvent(event: Event.loadAvatarsFail(error: error))
        }
        
        isLoading = false
    }
    
    func onAvatarPressed(avatar: AvatarModel, path: Binding<[TabbarPathOption]>) {
        path.wrappedValue.append(.chat(avatarId: avatar.avatarId, chat: nil))
        interactor.trackEvent(event: Event.avatarPressed(avatar: avatar))
    }
    
    // MARK: - Helper Types
    
    enum Event: LoggableEvent {
        case loadAvatarsStart
        case loadAvatarsSuccess
        case loadAvatarsFail(error: Error)
        case avatarPressed(avatar: AvatarModel)
        
        var eventName: String {
            switch self {
            case .loadAvatarsStart:               return "CategoryList_LoadAvatars_Start"
            case .loadAvatarsSuccess:             return "CategoryList_LoadAvatars_Success"
            case .loadAvatarsFail:                return "CategoryList_LoadAvatars_Fail"
            case .avatarPressed:                  return "CategoryList_Avatars_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .loadAvatarsFail(error: let error):
                return error.eventParameters
            case .avatarPressed(avatar: let avatar):
                return avatar.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .loadAvatarsFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
