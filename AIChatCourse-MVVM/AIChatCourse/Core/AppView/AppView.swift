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
    
    @Environment(DependencyContainer.self) private var container
    @Environment(\.scenePhase) private var scenePhase
    
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
                        TabBarView()
                    },
                    onBoardingView: {
                        WelcomeView(
                            viewModel: WelcomeViewModel(interactor: CoreInteractor(container: container))
                        )
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
    
    return AppView(
        viewModel: AppViewViewModel(interactor: CoreInteractor(container: container))
    )
    .environment(container)
    .previewEnvironment()
}

#Preview("AppView - OnBoarding") {
    let container = DevPreview.shared.container
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: nil)))
    container.register(UserManager.self, service: UserManager(services: MockUserServices(user: nil)))
    container.register(AppState.self, service: AppState(showTabBar: false))
    
    return AppView(
        viewModel: AppViewViewModel(interactor: CoreInteractor(container: container))
    )
    .environment(container)
    .previewEnvironment()
}
