//
//  ExploreView.swift
//  AIChatCourse
//
//  Created by Tung Le on 1/10/2025.
//
import SwiftUI

struct ExploreView: View {
    
    @Environment(DependencyContainer.self) private var container
    
    @State var viewModel: ExploreViewModel

    var body: some View {
        NavigationStack(path: $viewModel.path) {
            List {
                if viewModel.featuredAvatars.isEmpty && viewModel.popularAvatars.isEmpty {
                    ZStack {
                        if viewModel.isLoadingFeatured || viewModel.isLoadingPopular {
                            loadingIndicator
                        } else {
                            errorMessageView
                        }
                    }
                    .removeListRowFormatting()
                }
                
                if !viewModel.popularAvatars.isEmpty {
                    if viewModel.categoryRowTest == .top {
                        categoriesSection
                    }
                }
                
                if !viewModel.featuredAvatars.isEmpty {
                    featuredSection
                }
                if !viewModel.popularAvatars.isEmpty {
                    if viewModel.categoryRowTest == .original {
                        categoriesSection
                    }
                    popularSection
                }
            }
            .navigationTitle("Explore")
            .screenAppearAnalytics(name: "ExploreView")
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.showDevSettingButton {
                        devSettingButton
                    }
                }
                
                ToolbarItem(content: {
                    if viewModel.showNotificationButton {
                        pushNotificationButton
                    }
                })
            })
            .sheet(isPresented: $viewModel.showDevSetting, content: {
                DevSettingsView(viewModel: DevSettingsViewModel(interactor: CoreInteractor(container: container)))
            })
            .sheet(isPresented: $viewModel.showCreateAccountView, content: {
                CreateAccountView(
                    viewModel: CreateAccountViewModel(interactor: CoreInteractor(container: container))
                )
                .presentationDetents([.medium])
            })
            .navigationDestinationForTabbarModule(path: $viewModel.path)
            .showModal(showModal: $viewModel.showPushNotificationModal, content: {
                pushNotificationModal
            })
            .task {
                await viewModel.loadFeaturedAvatars()
            }
            .task {
                await viewModel.loadPopularAvatars()
            }
            .task {
                await viewModel.handleShowPushNotificatioButton()
            }
            .onFirstAppear {
                viewModel.schedulePushNotification()
                viewModel.showCreateAccountScreenIfNeeded()
            }
            .onOpenURL { url in
                viewModel.handleDeepLink(url: url)
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
    
    private var pushNotificationButton: some View {
        Image(systemName: "bell.fill")
            .font(.headline)
            .padding(4)
            .tappableBackground()
            .anyButton {
                viewModel.onPushNotificationPressed()
            }
    }

    private var devSettingButton: some View {
        Text("DEV 🤫")
            .badgeButton()
            .anyButton(.press) {
                viewModel.onDevSettingPressed()
            }
    }
    
    private var errorMessageView: some View {
        VStack {
            Text("Error")
                .font(.headline)
            Text("Please check your internet connection and try again.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("Try again") {
                viewModel.onTryAgainPressed()
            }
            .foregroundStyle(.blue)
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
        .padding(40)
    }
    
    private var loadingIndicator: some View {
        ProgressView()
            .padding(40)
            .frame(maxWidth: .infinity)
    }

    private var featuredSection: some View {
        Section {
            ZStack {
                CarouselView(items: viewModel.featuredAvatars) { avatar in
                    HeroCellView(
                        title: avatar.name,
                        subTitle: avatar.characterDescription,
                        imageName: avatar.profileImageName
                    )
                    .anyButton {
                        viewModel.onAvatarPressed(avatar: avatar)
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
                        ForEach(viewModel.categories, id: \.self) { category in
                            let imageName = viewModel.popularAvatars.last(where: { $0.characterOption == category})?.profileImageName
                            if let imageName {
                                CategoryCellView(
                                    title: category.plural.capitalized,
                                    imageName: imageName
                                )
                                .anyButton {
                                    viewModel.onCategoryPressed(category: category, imageName: imageName)
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
            ForEach(viewModel.popularAvatars, id: \.self) { avatar in
                CustomListCellView(
                    imageName: avatar.profileImageName,
                    title: avatar.name,
                    subtitle: avatar.characterDescription
                )
                .anyButton(.highlight, action: {
                    viewModel.onAvatarPressed(avatar: avatar)
                })
                .removeListRowFormatting()
            }
        } header: {
            Text("Popular")
        }
    }
    
} // 🧱

#Preview("Has data") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(service: MockAvatarService()))
    
    return ExploreView(viewModel: ExploreViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvironment()
}

#Preview("Has data w/ Create Acc Test") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(service: MockAvatarService()))
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: .mock(isAnonymous: true))))
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(createAccountTest: true)))
    
    return ExploreView(viewModel: ExploreViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvironment()
}

#Preview("CategoryRowTest: original") {
    let container = DevPreview.shared.container
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(categoryRowTest: .original)))
    
    return ExploreView(viewModel: ExploreViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvironment()
}

#Preview("CategoryRowTest: top") {
    let container = DevPreview.shared.container
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(categoryRowTest: .top)))
    
    return ExploreView(viewModel: ExploreViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvironment()
}

#Preview("CategoryRowTest: hidden") {
    let container = DevPreview.shared.container
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(categoryRowTest: .hidden)))
    
    return ExploreView(viewModel: ExploreViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvironment()
}

#Preview("No data") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(service: MockAvatarService(avatars: [], delay: 2)))
    
    return ExploreView(viewModel: ExploreViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvironment()
}

#Preview("Slow loading") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(service: MockAvatarService(delay: 10)))
    
    return ExploreView(viewModel: ExploreViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvironment()
}
