//
//  ExploreView.swift
//  AIChatCourse
//
//  Created by Tung Le on 1/10/2025.
//

import SwiftUI

struct ExploreView: View {
    
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(LogManager.self) private var logManager
    @Environment(PushManager.self) private var pushManager
    @Environment(AuthManager.self) private var authManager
    @Environment(ABTestManager.self) private var abTestManager
    
    @State private var categories: [CharacterOption] = CharacterOption.allCases
    
    @State private var featuredAvatars: [AvatarModel] = []
    @State private var popularAvatars: [AvatarModel] = []
    @State private var isLoadingFeatured: Bool = true
    @State private var isLoadingPopular: Bool = true
    @State private var showDevSetting: Bool = false
    @State private var showNotificationButton: Bool = false
    @State private var showPushNotificationModal: Bool = false
    @State private var showCreateAccountView: Bool = false
    
    @State private var path: [NavigationPathOption] = []
    
    private var showDevSettingButton: Bool {
        #if DEV || MOCK
        return true
        #else
        return false
        #endif
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                if featuredAvatars.isEmpty && popularAvatars.isEmpty {
                    ZStack {
                        if isLoadingFeatured || isLoadingPopular {
                            loadingIndicator
                        } else {
                            errorMessageView
                        }
                    }
                    .removeListRowFormatting()
                }
                
                if !popularAvatars.isEmpty {
                    if abTestManager.activeTests.categoryRowTest == .top {
                        categoriesSection
                    }
                }
                
                if !featuredAvatars.isEmpty {
                    featuredSection
                }
                if !popularAvatars.isEmpty {
                    if abTestManager.activeTests.categoryRowTest == .original {
                        categoriesSection
                    }
                    popularSection
                }
            }
            .navigationTitle("Explore")
            .screenAppearAnalytics(name: "ExploreView")
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    if showDevSettingButton {
                        devSettingButton
                    }
                }
                
                ToolbarItem(content: {
                    if showNotificationButton {
                        pushNotificationButton
                    }
                })
            })
            .sheet(isPresented: $showDevSetting, content: {
                DevSettingsView()
            })
            .sheet(isPresented: $showCreateAccountView, content: {
                CreateAccountView()
                    .presentationDetents([.medium])
            })
            .navigationDestinationForCoreModule(path: $path)
            .showModal(showModal: $showPushNotificationModal, content: {
                pushNotificationModal
            })
            .task {
                await loadFeaturedAvatars()
            }
            .task {
                await loadPopularAvatars()
            }
            .task {
                await handleShowPushNotificatioButton()
            }
            .onFirstAppear {
                schedulePushNotification()
                showCreateAccountScreenIfNeeded()
            }
            .onOpenURL { url in
                handleDeepLink(url: url)
            }
        }
    }
    
    // MARK: - Helper - Views
    private var pushNotificationModal: some View {
        CustomModalView(
            title: "Enable Push Notification?",
            subtitle: "We'll send you reminders and updates!",
            primaryButtonTitle: "Enable",
            primaryButtonAction: {
                
            },
            secondaryButtonTitle: "Cancel",
            secondaryButtonAction: {
                
            }
        )
    }
    /// ----- helpers
    private func onEnablePushNotificationPressed() {
        showPushNotificationModal = false
        
        Task {
            let isAuthorized = try await pushManager.requestAuthorization()
            logManager.trackEvent(event: Event.pushNotifsEnable(isAuthorized: isAuthorized))
            await handleShowPushNotificatioButton()
        }
    }
    private func onCanclePushNotificationPressed() {
        showPushNotificationModal = false
        logManager.trackEvent(event: Event.pushNotifsCancel)

    }
    
    private var pushNotificationButton: some View {
        Image(systemName: "bell.fill")
            .font(.headline)
            .padding(4)
            .tappableBackground()
            .anyButton {
                onPushNotificationPressed()
            }
    }
    /// ----- helper
    private func onPushNotificationPressed() {
        showPushNotificationModal = true
        logManager.trackEvent(event: Event.pushNotifsStart)
    }

    private var devSettingButton: some View {
        Text("DEV 🤫")
            .badgeButton()
            .anyButton(.press) {
                onDevSettingPressed()
            }
    }
    /// ----- helper
    private func onDevSettingPressed() {
        logManager.trackEvent(event: Event.devSettingsPressed)
        showDevSetting = true
    }
    
    private var errorMessageView: some View {
        VStack {
            Text("Error")
                .font(.headline)
            Text("Please check your internet connection and try again.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("Try again") {
                onTryAgainPressed()
            }
            .foregroundStyle(.blue)
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
        .padding(40)
    }
    /// --- helper func
    private func onTryAgainPressed() {
        isLoadingPopular = true
        isLoadingFeatured = true
        logManager.trackEvent(event: Event.tryAgainPressed)
        
        Task {
            await loadFeaturedAvatars()
        }
        Task {
            await loadPopularAvatars()
        }
    }
    
    private var loadingIndicator: some View {
        ProgressView()
            .padding(40)
            .frame(maxWidth: .infinity)
    }
    
    private func loadFeaturedAvatars() async {
        /// If already loaded, no need to fetch again
        guard featuredAvatars.isEmpty else { return }
        logManager.trackEvent(event: Event.loadFeaturedAvatarsStart)
        
        do {
            featuredAvatars = try await avatarManager.getFeaturedAvatar()
            logManager.trackEvent(event: Event.loadFeaturedAvatarsSuccess(count: featuredAvatars.count))

        } catch {
            print("Error loading featured avatars: \(error)")
            logManager.trackEvent(event: Event.loadPopularAvatarsFail(error: error))

        }
        
        isLoadingFeatured = false
    }
    
    private func loadPopularAvatars() async {
        /// If already loaded, no need to fetch again
        guard popularAvatars.isEmpty else { return }
        logManager.trackEvent(event: Event.loadPopularAvatarsStart)
        
        do {
            popularAvatars = try await avatarManager.getPopularAvatar()
            logManager.trackEvent(event: Event.loadPopularAvatarsSuccess(count: popularAvatars.count))
        } catch {
            logManager.trackEvent(event: Event.loadFeaturedAvatarsFail(error: error))
        }
        
        isLoadingPopular = false
    }
    
    private var featuredSection: some View {
        Section {
            ZStack {
                CarouselView(items: featuredAvatars) { avatar in
                    HeroCellView(
                        title: avatar.name,
                        subTitle: avatar.characterDescription,
                        imageName: avatar.profileImageName
                    )
                    .anyButton {
                        onAvatarPressed(avatar: avatar)
                    }
                }
            }
            .removeListRowFormatting()
        } header: {
            Text("Feature")
        }
    }
    
    private var categoriesSection: some View {
        Section {
            ZStack {
                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        ForEach(categories, id: \.self) { category in
                            let imageName = popularAvatars.last(where: { $0.characterOption == category})?.profileImageName
                            if let imageName {
                                CategoryCellView(
                                    title: category.plural.capitalized,
                                    imageName: imageName
                                )
                                .anyButton {
                                    onCategoryPressed(category: category, imageName: imageName)
                                }
                            }
                        }
                    }
                }
                .frame(height: 140)
                .scrollTargetLayout()
                .scrollTargetBehavior(.viewAligned)
                .scrollIndicators(.hidden)
            }
            .removeListRowFormatting()
        } header: {
            Text("Categories")
        }
    }
    
    private var popularSection: some View {
        Section {
            ForEach(popularAvatars, id: \.self) { avatar in
                CustomListCellView(
                    imageName: avatar.profileImageName,
                    title: avatar.name,
                    subtitle: avatar.characterDescription
                )
                .anyButton(.highlight, action: {
                    onAvatarPressed(avatar: avatar)
                })
                .removeListRowFormatting()
            }
        } header: {
            Text("Popular")
        }
    }
    
    // MARK: - Helper - Func
    private func handleDeepLink(url: URL) {
        logManager.trackEvent(event: Event.deeplinkStart)
        
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems
        else {
            logManager.trackEvent(event: Event.deeplinkNoQueryItems)
            return
        }
        
        for queryItem in queryItems {
            if queryItem.name == "category", let value = queryItem.value, let category = CharacterOption(rawValue: value) {
                let imageName = popularAvatars.first(where: { $0.characterOption == category })?.profileImageName ?? Constants.randomImage
                path.append(.category(category: category, imageName: imageName))
                logManager.trackEvent(event: Event.deeplinkCategory(category: category))
                return
            }
        }
        
        logManager.trackEvent(event: Event.deeplinkUnknown)
    }
    
    private func schedulePushNotification() {
        pushManager.schedulePushNotificationsForTheNextWeek()
    }
    
    private func showCreateAccountScreenIfNeeded() {
        Task {
            try? await Task.sleep(for: .seconds(2))
            
            /// If the user doesn't already have an account (anonymous)
            /// If the user is in our AB test
            guard authManager.auth?.isAnonymous == true &&
                  abTestManager.activeTests.createAccountTest == true
            else {
                return
            }
            
            showCreateAccountView = true
        }
    }
    
    private func handleShowPushNotificatioButton() async {
        showNotificationButton = await pushManager.canRequestAuthorization()
    }
    
    private func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
        logManager.trackEvent(event: Event.avatarPressed(avatar: avatar))
    }
    
    private func onCategoryPressed(category: CharacterOption, imageName: String) {
        path.append(.category(category: category, imageName: imageName))
        logManager.trackEvent(event: Event.categoryPressed(category: category))
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
    
} // 🧱

#Preview("Has data") {
    ExploreView()
        .environment(AvatarManager(service: MockAvatarService()))
        .previewEnvironment()
}

#Preview("Has data w/ Create Acc Test") {
    ExploreView()
        .environment(AvatarManager(service: MockAvatarService()))
        .environment(AuthManager(service: MockAuthService(user: .mock(isAnonymous: true))))
        .environment(ABTestManager(service: MockABTestService(createAccountTest: true)))
        .previewEnvironment()
}

#Preview("CategoryRowTest: original") {
    ExploreView()
        .environment(ABTestManager(service: MockABTestService(categoryRowTest: .original)))
        .previewEnvironment()
}

#Preview("CategoryRowTest: top") {
    ExploreView()
        .environment(ABTestManager(service: MockABTestService(categoryRowTest: .top)))
        .previewEnvironment()
}

#Preview("CategoryRowTest: hidden") {
    ExploreView()
        .environment(ABTestManager(service: MockABTestService(categoryRowTest: .hidden)))
        .previewEnvironment()
}

#Preview("No data") {
    ExploreView()
        .environment(AvatarManager(service: MockAvatarService(avatars: [], delay: 2)))
        .previewEnvironment()
}

#Preview("Slow loading") {
    ExploreView()
        .environment(AvatarManager(service: MockAvatarService(delay: 10)))
        .previewEnvironment()
}
