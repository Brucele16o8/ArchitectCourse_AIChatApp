//
//  ProfileView.swift
//  AIChatCourse
//
//  Created by Tung Le on 1/10/2025.
//

import SwiftUI

struct ProfileView: View {
    
    @Environment(DependencyContainer.self) private var container
    
    @State var viewModel: ProfileViewModel
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            List {
                myInfoSection
                myAvatarSection
            }
            .navigationTitle("Profile")
            .navigationDestinationForTabbarModule(path: $viewModel.path)
            .showCustomAlert(alert: $viewModel.showAlert)
            .screenAppearAnalytics(name: "ProfileView")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    settingsButton
                }
            }
        }
        .sheet(isPresented: $viewModel.showSettingsView) {
            SettingsView(
                viewModel: SettingsViewModel(interactor: CoreInteractor(container: container))
            )
        }
        .fullScreenCover(
            isPresented: $viewModel.showCreateAvatarView,
            onDismiss: {
                Task {
                    await viewModel.loadData()
                }
            },
            content: {
                CreateAvatarView(
                    viewModel: CreateAvatarViewModel(interactor: CoreInteractor(container: container))
                )
        })
        .task {
            await viewModel.loadData()
        }
    }
    
    // MARK: - View Variable
    private var myInfoSection: some View {
        Section {
            ZStack {
                Circle()
                    .fill(viewModel.currentUser?.profileColorCalculated ?? .accent)
            }
            .frame(width: 100, height: 100)
            .frame(maxWidth: .infinity)
            .removeListRowFormatting()
        }
    }
    
    private var myAvatarSection: some View {
        Section {
            if viewModel.myAvatars.isEmpty {
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Text("Click + to create an avatar")
                    }
                }
                .padding(50)
                .frame(maxWidth: .infinity)
                .foregroundStyle(.secondary)
                .removeListRowFormatting()
            } else {
                ForEach(viewModel.myAvatars, id: \.self) { avatar in
                    CustomListCellView(
                        imageName: avatar.profileImageName,
                        title: avatar.name,
                        subtitle: nil
                    )
                    .anyButton(.highlight, action: {
                        viewModel.onAvatarPressed(avatar: avatar)
                    })
                    .removeListRowFormatting()
                }
                .onDelete { indexSet in
                    viewModel.onDeleteAvatar(indexSet: indexSet)
                }
            }
        } header: {
            HStack(spacing: 0) {
                Text("My Avatar")
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .font(.title)
                    .foregroundColor(.accent)
                    .anyButton {
                        viewModel.onNewAvatarButtonPressed()
                    }
            }
        }
    }
    
    private var settingsButton: some View {
        Image(systemName: "gear")
            .font(.headline)
            .foregroundStyle(.accent)
            .anyButton {
                viewModel.onSettingsButotnPressed()
            }
    }

} // 🧱

#Preview {
    ProfileView(
        viewModel: ProfileViewModel(interactor: CoreInteractor(container: DevPreview.shared.container))
    )
    .previewEnvironment()
}
