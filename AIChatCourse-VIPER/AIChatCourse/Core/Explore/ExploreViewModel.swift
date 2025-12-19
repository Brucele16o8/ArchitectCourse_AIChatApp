//
//  ExploreViewModel.swift
//  AIChatCourse
//
//  Created by Tung Le on 15/12/2025.
//
import SwiftUI

@MainActor
protocol ExploreInteractor {
    var categoryRowTest: CategoryRowTestOption { get }
    var createAccountTest: Bool { get }
    var auth: UserAuthInfo? { get }
    
    func trackEvent(event: LoggableEvent)
    func schedulePushNotificationsForTheNextWeek()
    func canRequestAuthorization() async -> Bool
    func requestAuthorization() async throws -> Bool
    func getFeaturedAvatar() async throws -> [AvatarModel]
    func getPopularAvatar() async throws -> [AvatarModel]
}

extension CoreInteractor: ExploreInteractor { }

@Observable
@MainActor
class ExploreViewModel {
    
    let interactor: ExploreInteractor
    
    private(set) var categories: [CharacterOption] = CharacterOption.allCases
    private(set) var featuredAvatars: [AvatarModel] = []
    private(set) var popularAvatars: [AvatarModel] = []
    private(set) var isLoadingFeatured: Bool = true
    private(set) var isLoadingPopular: Bool = true
    private(set) var showNotificationButton: Bool = false

    var showDevSetting: Bool = false
    var showPushNotificationModal: Bool = false
    var showCreateAccountView: Bool = false
    var path: [TabbarPathOption] = []
    
    var showDevSettingButton: Bool {
        #if DEV || MOCK
        return true
        #else
        return false
        #endif
    }
    
    var categoryRowTest: CategoryRowTestOption {
        interactor.categoryRowTest
    }
    
    init(interactor: ExploreInteractor) {
        self.interactor = interactor
    }
    
    // MARK: - Methods
    func handleDeepLink(url: URL) {
        interactor.trackEvent(event: Event.deeplinkStart)
        
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems
        else {
            interactor.trackEvent(event: Event.deeplinkNoQueryItems)
            return
        }
        
        for queryItem in queryItems {
            if queryItem.name == "category", let value = queryItem.value, let category = CharacterOption(rawValue: value) {
                let imageName = popularAvatars.first(where: { $0.characterOption == category })?.profileImageName ?? Constants.randomImage
                path.append(.category(category: category, imageName: imageName))
                interactor.trackEvent(event: Event.deeplinkCategory(category: category))
                return
            }
        }
        
        interactor.trackEvent(event: Event.deeplinkUnknown)
    }
    
    func schedulePushNotification() {
        interactor.schedulePushNotificationsForTheNextWeek()
    }
    
    func showCreateAccountScreenIfNeeded() {
        Task {
            try? await Task.sleep(for: .seconds(2))
            
            /// If the user doesn't already have an account (anonymous)
            /// If the user is in our AB test
            guard interactor.auth?.isAnonymous == true &&
                  interactor.createAccountTest == true
            else {
                return
            }
            
            showCreateAccountView = true
        }
    }
    
    func handleShowPushNotificatioButton() async {
        showNotificationButton = await interactor.canRequestAuthorization()
    }
    
    func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
        interactor.trackEvent(event: Event.avatarPressed(avatar: avatar))
    }
    
    func onCategoryPressed(category: CharacterOption, imageName: String) {
        path.append(.category(category: category, imageName: imageName))
        interactor.trackEvent(event: Event.categoryPressed(category: category))
    }
    
    // MARK: - Method - Helpers
    func onEnablePushNotificationPressed() {
        showPushNotificationModal = false
        
        Task {
            let isAuthorized = try await interactor.requestAuthorization()
            interactor.trackEvent(event: Event.pushNotifsEnable(isAuthorized: isAuthorized))
            await handleShowPushNotificatioButton()
        }
    }
    func onCanclePushNotificationPressed() {
        showPushNotificationModal = false
        interactor.trackEvent(event: Event.pushNotifsCancel)

    }
    
    func onPushNotificationPressed() {
        showPushNotificationModal = true
        interactor.trackEvent(event: Event.pushNotifsStart)
    }

    func onTryAgainPressed() {
        isLoadingPopular = true
        isLoadingFeatured = true
        interactor.trackEvent(event: Event.tryAgainPressed)
        
        Task {
            await loadFeaturedAvatars()
        }
        Task {
            await loadPopularAvatars()
        }
    }
    
    func loadFeaturedAvatars() async {
        /// If already loaded, no need to fetch again
        guard featuredAvatars.isEmpty else { return }
        interactor.trackEvent(event: Event.loadFeaturedAvatarsStart)
        
        do {
            featuredAvatars = try await interactor.getFeaturedAvatar()
            interactor.trackEvent(event: Event.loadFeaturedAvatarsSuccess(count: featuredAvatars.count))

        } catch {
            print("Error loading featured avatars: \(error)")
            interactor.trackEvent(event: Event.loadPopularAvatarsFail(error: error))

        }
        
        isLoadingFeatured = false
    }
    
    func onDevSettingPressed() {
        interactor.trackEvent(event: Event.devSettingsPressed)
        showDevSetting = true
    }
    
    func loadPopularAvatars() async {
        /// If already loaded, no need to fetch again
        guard popularAvatars.isEmpty else { return }
        interactor.trackEvent(event: Event.loadPopularAvatarsStart)
        
        do {
            popularAvatars = try await interactor.getPopularAvatar()
            interactor.trackEvent(event: Event.loadPopularAvatarsSuccess(count: popularAvatars.count))
        } catch {
            interactor.trackEvent(event: Event.loadFeaturedAvatarsFail(error: error))
        }
        
        isLoadingPopular = false
    }
    
    // MARK: - Events
    enum Event: LoggableEvent {
        case devSettingsPressed
        case tryAgainPressed
        case loadFeaturedAvatarsStart
        case loadFeaturedAvatarsSuccess(count: Int)
        case loadFeaturedAvatarsFail(error: Error)
        case loadPopularAvatarsStart
        case loadPopularAvatarsSuccess(count: Int)
        case loadPopularAvatarsFail(error: Error)
        case avatarPressed(avatar: AvatarModel)
        case categoryPressed(category: CharacterOption)
        case pushNotifsStart
        case pushNotifsEnable(isAuthorized: Bool)
        case pushNotifsCancel
        case deeplinkStart
        case deeplinkNoQueryItems
        case deeplinkCategory(category: CharacterOption)
        case deeplinkUnknown
        
        var eventName: String {
            switch self {
            case .devSettingsPressed:            return "ExploreView_DevSettings_Pressed"
            case .tryAgainPressed:               return "ExploreView_TryAgain_Pressed"
            case .loadFeaturedAvatarsStart:      return "ExploreView_LoadFeaturedAvatars_Start"
            case .loadFeaturedAvatarsSuccess:    return "ExploreView_LoadFeaturedAvatars_Success"
            case .loadFeaturedAvatarsFail:       return "ExploreView_LoadFeaturedAvatars_Fail"
            case .loadPopularAvatarsStart:       return "ExploreView_LoadPopularAvatars_Start"
            case .loadPopularAvatarsSuccess:     return "ExploreView_LoadPopularAvatars_Success"
            case .loadPopularAvatarsFail:        return "ExploreView_LoadPopularAvatars_Fail"
            case .avatarPressed:                 return "ExploreView_Avatar_Pressed"
            case .categoryPressed:               return "ExploreView_Category_Pressed"
            case .pushNotifsStart:               return "ExploreView_PushNotifs_Start"
            case .pushNotifsEnable:              return "ExploreView_PushNotifs_Enable"
            case .pushNotifsCancel:              return "ExploreView_PushNotifs_Cancel"
            case .deeplinkStart:                 return "ExploreView_DeepLink_Start"
            case .deeplinkNoQueryItems:          return "ExploreView_DeepLink_NoItems"
            case .deeplinkCategory:              return "ExploreView_DeepLink_Category"
            case .deeplinkUnknown:               return "ExploreView_DeepLink_Unknown"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .loadPopularAvatarsSuccess(count: let count), .loadFeaturedAvatarsSuccess(count: let count):
                return [
                    "avatars_count": count
                ]
            case .loadPopularAvatarsFail(error: let error), .loadFeaturedAvatarsFail(error: let error):
                return error.eventParameters
            case .avatarPressed(avatar: let avatar):
                return avatar.eventParameters
            case .categoryPressed(category: let category), .deeplinkCategory(category: let category):
                return [
                    "category": category.rawValue
                ]
            case .pushNotifsEnable(isAuthorized: let isAuthorized):
                return [
                    "isAuthorized": isAuthorized
                ]
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .loadPopularAvatarsFail, .loadFeaturedAvatarsFail, .deeplinkUnknown:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
