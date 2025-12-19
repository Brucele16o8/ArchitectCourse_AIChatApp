//
//  SettingsView.swift
//  AIChatCourse
//
//  Created by Tung Le on 1/10/2025.
//

import SwiftUI
import SwiftfulUtilities

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(DependencyContainer.self) private var container
    
    @State var viewModel: SettingsViewModel
    
    var body: some View {
        NavigationStack {
            List {
                accountSection
                purchaseSection
                applicationSection
            }
            .lineLimit(1)
            .minimumScaleFactor(0.4)
            .navigationTitle("Settings")
            .sheet(isPresented: $viewModel.showCreateAccountView, onDismiss: {
                viewModel.setAnonymousAccountStatus()
            }, content: {
                CreateAccountView(
                    viewModel: CreateAccountViewModel(interactor: CoreInteractor(container: container))
                )
                    .presentationDetents([.medium])
            })
            .onAppear {
                viewModel.setAnonymousAccountStatus()
            }
            .showCustomAlert(alert: $viewModel.showAlert)
            .screenAppearAnalytics(name: "SettingsView")
            .showModal(showModal: $viewModel.showRatingsModal) {
                ratingsModal
            }
        }
    }

    // MARK: - Subviews
    private var ratingsModal: some View {
        CustomModalView(
            title: "Are you enjoying AIChat?",
            subtitle: "We'd love to hear your feedback!",
            primaryButtonTitle: "Yes",
            primaryButtonAction: {
                viewModel.onEnjoyingAppYesPressed()
            },
            secondaryButtonTitle: "No",
            secondaryButtonAction: {
                viewModel.onEnjoyingAppNoPressed()
            }
        )
    }
    
    private var accountSection: some View {
        Section {
            if viewModel.isAnonymousUser {
                Text("Save & back-up account")
                    .rowFormatting()
                    .anyButton(.highlight) {
                        viewModel.onCreateAccountPressed()
                    }
                    .removeListRowFormatting()
            } else {
                Text("Sign out")
                    .rowFormatting()
                    .anyButton(.highlight) {
                        viewModel.onSignOutPressed(onDismiss: {
                            await dismissScreen()
                        })
                    }
                    .removeListRowFormatting()
            }

            Text("Delete Account")
                .foregroundStyle(.red)
                .rowFormatting()
                .anyButton(.highlight) {
                    viewModel.onDeleteAccountPressed(onDismiss: {
                        await dismissScreen()
                    })
                }
                .removeListRowFormatting()
        } header: {
            Text("Account".uppercased())
        }
    }
    
    private var purchaseSection: some View {
        Section {
            HStack {
                Text("Account status: \(viewModel.isPremium ? "PREMIUM" : "FREE")")
                if viewModel.isPremium {
                    Spacer()
                    Text("MANAGE")
                        .badgeButton()
                }
            }
            .rowFormatting()
            .anyButton(.highlight) {
                /// action !!!
            }
            .removeListRowFormatting()
            .disabled(!viewModel.isPremium)

        } header: {
            Text("Account".uppercased())
        }
    }
    
    private var applicationSection: some View {
        Section {
            Text("Rate us on the App Store!")
                .foregroundStyle(.blue)
                .rowFormatting()
                .anyButton(.highlight, action: {
                    viewModel.onRatingButtonPressed()
                })
                .removeListRowFormatting()
            
            HStack {
                Text("Version")
                Spacer()
                Text(Utilities.appVersion ?? "")
                    .foregroundStyle(.secondary)
            }
            .rowFormatting()
            .removeListRowFormatting()
            
            HStack {
                Text("Build Number")
                Spacer()
                Text(Utilities.buildNumber ?? "")
                    .foregroundStyle(.secondary)
            }
            .rowFormatting()
            .removeListRowFormatting()
            
            Text("Contact us")
                .foregroundStyle(.blue)
                .rowFormatting()
                .anyButton(.highlight, action: {
                    viewModel.onContactUsPressed()
                })
                .removeListRowFormatting()
            
        } header: {
            Text("Application".uppercased())
        } footer: {
            Text("Created by Swiftful Thinking.\nLearn more at www.swiftful-thinking.com")
                .baselineOffset(6)
        }
    }
    
    // MARK: - Methods
    private func dismissScreen() async {
        dismiss()
        try? await Task.sleep(for: .seconds(0.5))
    }
    
} // == 🧱

// MARK: - Extension
private struct RowFormattingViewModifier: ViewModifier {
    
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
            .background(colorScheme.backgroundPrimary)
    }
}

fileprivate extension View {
    
    func rowFormatting() -> some View {
        modifier(RowFormattingViewModifier())
    }
    
} /// 🧱

#Preview("No auth") {
    let container = DevPreview.shared.container
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: nil)))
    container.register(UserManager.self, service: UserManager(services: MockUserServices(user: nil)))
    
    return SettingsView(
        viewModel: SettingsViewModel(interactor: CoreInteractor(container: container))
    )
    .environment(container)
    .previewEnvironment()
}
#Preview("Anonymous") {
    let container = DevPreview.shared.container
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: true))))
    container.register(UserManager.self, service: UserManager(services: MockUserServices(user: .mock)))
    
    return SettingsView(
        viewModel: SettingsViewModel(interactor: CoreInteractor(container: container))
    )
    .environment(container)
    .previewEnvironment()
}
#Preview("Not anonymous") {
    let container = DevPreview.shared.container
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: false))))
    container.register(UserManager.self, service: UserManager(services: MockUserServices(user: .mock)))
    
    return SettingsView(
        viewModel: SettingsViewModel(interactor: CoreInteractor(container: container))
    )
    .environment(container)
    .previewEnvironment()
}
