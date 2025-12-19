//
//  AppView.swift
//  AIChatCourse
//
//  Created by Tung Le on 29/9/2025.
//

import SwiftUI
import SwiftfulUtilities

struct AppView: View {
    
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
    @Environment(PurchaseManager.self) private var purchaseManager
    @Environment(\.scenePhase) private var scenePhase
    
    @State var appState: AppState = .init()
    
    var body: some View {
        RootView(
            delegate: RootDelegate(
                onApplicationDidAppear: nil,
                onApplicationWillEnterForeground: { _ in
                    Task {
                        await checkUserStatus()
                    }
                },
                onApplicationDidBecomeActive: nil,
                onApplicationWillResignActive: nil,
                onApplicationDidEnterBackground: nil,
                onApplicationWillTerminate: nil
            ),
            content: {
                AppViewBuidlder(
                    showTabBar: appState.showTabBar,
                    tabbarView: {
                        TabBarView()
                    },
                    onBoardingView: {
                        WelcomeView()
                    }
                )
                .environment(appState)
                .task {
                    await checkUserStatus()
                }
                .task {
                    try? await Task.sleep(for: .seconds(2))
                    await showATPromptTIfNeeded()
                }
                .onChange(of: appState.showTabBar) { _, showTabBar in
                    if !showTabBar {
                        Task {
                            await checkUserStatus()
                        }
                    }
                }
            }
        )
    }
    
    // MARK: Events
    enum Event: LoggableEvent {
        case existingAuthStart
        case existingAuthFail(error: Error)
        case anonAuthStart
        case anonAuthSuccess
        case anonAuthFail(error: Error)
        case attStatus(dict: [String: Any])
        
        var eventName: String {
            switch self {
            case .existingAuthStart:     return "AppView_ExistingAuth_Start"
            case .existingAuthFail:      return "AppView_ExistingAuth_Fail"
            case .anonAuthStart:         return "AppView_AnonAuth_Start"
            case .anonAuthSuccess:       return "AppView_AnonAuth_Success"
            case .anonAuthFail:          return "AppView_AnonAuth_Fail"
            case .attStatus:             return "AppView_ATTStatus"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .existingAuthFail(error: let error), .anonAuthFail(error: let error):
                return error.eventParameters
            case .attStatus(dict: let dict):
                return dict
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .existingAuthFail, .anonAuthFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
    
    // MARK: Methods
    private func showATPromptTIfNeeded() async {
        #if !DEBUG
        let status = await AppTrackingTransparencyHelper.requestTrackingAuthorization()
        logManager.trackEvent(event: Event.attStatus(dict: status.eventParameters))
        #endif
    }
    
    private func checkUserStatus() async {
        if let user = authManager.auth {
            /// User is authenticated !!!
            logManager.trackEvent(event: Event.existingAuthStart)
//            print("User is already authenticated: \(user.uid)")
            
            do {
                try await userManager.logIn(auth: user, isNewUser: false)
                try await purchaseManager.login(
                    userId: user.uid,
                    attributes: PurchaseProfileAttributes(
                        email: user.email,
                        firebaseAppInstanceId: FirebaseAnalyticsService.appInstanceID,
                        mixpanelDistinctId: MixPanelService.distinctId
                    )
                )
            } catch {
                logManager.trackEvent(event: Event.existingAuthFail(error: error))
//                print("Failed to log in to auth for existing user: \(user)")
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
        } else {
            /// User is not authenticated !!!
            do {
                let result = try await authManager.signInAnonymously()
                
                /// log into app
                logManager.trackEvent(event: Event.anonAuthStart)
//                print("Sign in anonymous success: \(result.user.uid)")
                
                /// Log in
                try await userManager.logIn(auth: result.user, isNewUser: result.isNewUser)
                try await purchaseManager.login(
                    userId: result.user.uid,
                    attributes: PurchaseProfileAttributes(
                        firebaseAppInstanceId: FirebaseAnalyticsService.appInstanceID,
                        mixpanelDistinctId: MixPanelService.distinctId
                    )
                )
                
            } catch {
                logManager.trackEvent(event: Event.anonAuthFail(error: error))
//                print("Failed to sign in anonymously and log in: \(error)")
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
        }
    }
    
} // 🧱

#Preview("AppView - Tabbar") {
    AppView(appState: AppState(showTabBar: true))
        .environment(UserManager(services: MockUserServices(user: .mock)))
        .environment(AuthManager(service: MockAuthService(user: .mock())))
        .previewEnvironment()
}

#Preview("AppView - OnBoarding") {
    AppView(appState: AppState(showTabBar: false))
        .environment(AuthManager(service: MockAuthService(user: nil)))
        .environment(UserManager(services: MockUserServices(user: nil)))
        .previewEnvironment()
}
