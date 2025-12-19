//
//  AppView.swift
//  AIChatCourse
//
//  Created by Tung Le on 29/9/2025.
//

import SwiftUI
import SwiftfulUtilities

struct AppView: View {
    
    @State var viewModel: AppViewViewModel
    
    @Environment(\.scenePhase) private var scenePhase
    
    @ViewBuilder var tabbarView: () -> AnyView
    @ViewBuilder var onboardingView: () -> AnyView
    
    var body: some View {
        RootView(
            delegate: RootDelegate(
                onApplicationDidAppear: nil,
                onApplicationWillEnterForeground: { _ in
                    Task {
                        await viewModel.checkUserStatus()
                    }
                },
                onApplicationDidBecomeActive: nil,
                onApplicationWillResignActive: nil,
                onApplicationDidEnterBackground: nil,
                onApplicationWillTerminate: nil
            ),
            content: {
                AppViewBuidlder(
                    showTabBar: viewModel.showTabbar,
                    tabbarView: {
                        tabbarView()
                    },
                    onBoardingView: {
                        onboardingView()
                    }
                )
                .task {
                    await viewModel.checkUserStatus()
                }
                .task {
                    try? await Task.sleep(for: .seconds(2))
                    await viewModel.showATPromptTIfNeeded()
                }
                .onChange(of: viewModel.showTabbar) { _, showTabBar in
                    if !showTabBar {
                        Task {
                            await viewModel.checkUserStatus()
                        }
                    }
                }
            }
        )
    }
    
} // 🧱

#Preview("AppView - Tabbar") {
    let container = DevPreview.shared.container
    container.register(AppState.self, service: AppState(showTabBar: true))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    
    return builder.appView()
        .previewEnvironment()
}

#Preview("AppView - OnBoarding") {
    let container = DevPreview.shared.container
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: nil)))
    container.register(UserManager.self, service: UserManager(services: MockUserServices(user: nil)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    
    return builder.appView()
        .previewEnvironment()
}
