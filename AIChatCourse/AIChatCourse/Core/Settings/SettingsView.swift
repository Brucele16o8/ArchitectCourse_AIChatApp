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
    @Environment(AppState.self) private var appState
    @Environment(AuthManager.self) private var authManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(ChatManager.self) private var chatManager
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
    @Environment(PurchaseManager.self) private var purchaseManager
    
    @State private var isPremium: Bool = false
    @State private var isAnonymousUser: Bool = false
    @State private var showCreateAccountView: Bool = false
    @State private var showAlert: AnyAppAlert?
    @State private var showRatingsModal: Bool = false
    
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
            .sheet(isPresented: $showCreateAccountView, onDismiss: {
                setAnonymousAccountStatus()
            }, content: {
                CreateAccountView()
                    .presentationDetents([.medium])
            })
            .onAppear {
                setAnonymousAccountStatus()
            }
            .showCustomAlert(alert: $showAlert)
            .screenAppearAnalytics(name: "SettingsView")
            .showModal(showModal: $showRatingsModal) {
                ratingsModal
            }
        }
    }

    // MARK: - Helper View
    /// 🧩
    private var ratingsModal: some View {
        CustomModalView(
            title: "Are you enjoying AIChat?",
            subtitle: "We'd love to hear your feedback!",
            primaryButtonTitle: "Yes",
            primaryButtonAction: {
                onEnjoyingAppYesPressed()
            },
            secondaryButtonTitle: "No",
            secondaryButtonAction: {
                onEnjoyingAppNoPressed()
            }
        )
    }
    
    /// 🧩
    private var accountSection: some View {
        Section {
            if isAnonymousUser {
                Text("Save & back-up account")
                    .rowFormatting()
                    .anyButton(.highlight) {
                        onCreateAccountPressed()
                    }
                    .removeListRowFormatting()
            } else {
                Text("Sign out")
                    .rowFormatting()
                    .anyButton(.highlight) {
                        onSignOutPressed()
                    }
                    .removeListRowFormatting()
            }

            Text("Delete Account")
                .foregroundStyle(.red)
                .rowFormatting()
                .anyButton(.highlight) {
                    onDeleteAccountPressed()
                }
                .removeListRowFormatting()
        } header: {
            Text("Account".uppercased())
        }
    }
    
    /// 🧩
    private var purchaseSection: some View {
        Section {
            HStack {
                Text("Account status: \(isPremium ? "PREMIUM" : "FREE")")
                if isPremium {
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
            .disabled(!isPremium)

        } header: {
            Text("Account".uppercased())
        }
    }
    
    /// 🧩
    private var applicationSection: some View {
        Section {
            Text("Rate us on the App Store!")
                .foregroundStyle(.blue)
                .rowFormatting()
                .anyButton(.highlight, action: {
                    onRatingButtonPressed()
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
                    onContactUsPressed()
                })
                .removeListRowFormatting()
            
        } header: {
            Text("Application".uppercased())
        } footer: {
            Text("Created by Swiftful Thinking.\nLearn more at www.swiftful-thinking.com")
                .baselineOffset(6)
        }
    }
    
    // MARK: - Method logic
    /// 🧩
    func onSignOutPressed() {
        Task {
            logManager.trackEvent(event: Event.signOutStart)
            
            do {
                try authManager.signOut()
                try await purchaseManager.logOut()
                userManager.signOut()
                logManager.trackEvent(event: Event.signOutSuccess)

                await dismissScreen()
            } catch {
                showAlert = AnyAppAlert(error: error)
                logManager.trackEvent(event: Event.signOutFail(error: error))
            }
        }
    }
    
    private func dismissScreen() async {
        dismiss()
        try? await Task.sleep(for: .seconds(0.5))
        appState.updateViewState(showTabBarView: false)
    }
    
    /// 🧩
    func onDeleteAccountPressed() {
        logManager.trackEvent(event: Event.deleteAccountStart)
        
        showAlert = AnyAppAlert(
            title: "Delete Account",
            subtitle: "This action is permanent and cannot be undone. Your data will be deleted from our server forever.",
            buttons: {
                AnyView(
                    Button("Delete", role: .destructive, action: {
                        onDeleteAccountConfirmed()
                    })
                )
            }
        )
    }
    /// 🧩
    private func onDeleteAccountConfirmed() {
        logManager.trackEvent(event: Event.deleteAccountStartConfirm)

        Task {
            do {
                let uid = try authManager.getAuthId()
                
                try await chatManager.deleteAllChatsForUser(userId: uid)
                
                try await avatarManager.removeAuthorIdFromAllUserAvatars(userId: uid)
                
                try await userManager.deleteCurrentUser()
                
                try await authManager.deleteAccount()
                
                try await purchaseManager.logOut()
                
//                async let deleteAccount: () = authManager.deleteAccount()
//                async let deleteUser: () = userManager.deleteCurrentUser()
//                async let deleteAvatars: () = avatarManager.removeAuthorIdFromAllUserAvatars(userId: uid)
//                async let deleteChats: () = chatManager.deleteAllChatsForUser(userId: uid)
                
//                let (_, _, _, _) = await (try deleteAccount, try deleteUser, try deleteAvatars, try deleteChats)
                logManager.deleteUserProfile()
                logManager.trackEvent(event: Event.deleteAccountSuccess)
                
                await dismissScreen()
            } catch {
                showAlert = AnyAppAlert(error: error)
                logManager.trackEvent(event: Event.deleteAccountFail(error: error))
            }
        }
    }
    
    /// 🧩
    private func onRatingButtonPressed() {
        logManager.trackEvent(event: Event.ratingsPressed)
        showRatingsModal = true
    }
    
    /// 🧩
    private func onEnjoyingAppYesPressed() {
        logManager.trackEvent(event: Event.ratingsYesPressed)
        showRatingsModal = false
        AppStoreRatingsHelper.requestRatingsReview()
    }
    
    /// 🧩
    private func onEnjoyingAppNoPressed() {
        logManager.trackEvent(event: Event.ratingsNoPressed)
        showRatingsModal = false
    }
    
    /// 🧩
    private func onContactUsPressed() {
        logManager.trackEvent(event: Event.contactUsPressed)
        
        let email = "brucele.tt168@gmail.com"
        let emailString = "mailto:\(email)"
        
        guard let url = URL(string: emailString), UIApplication.shared.canOpenURL(url) else {
            return
        }
        
        UIApplication.shared.open(url)
    }
    
    /// 🧩
    func onCreateAccountPressed() {
        showCreateAccountView = true
        logManager.trackEvent(event: Event.createAccountPressed)
    }
    
    /// 🧩
    func setAnonymousAccountStatus() {
        isAnonymousUser = authManager.auth?.isAnonymous == true
    }
    
    // MARK: - Events
    enum Event: LoggableEvent {
        case signOutStart
        case signOutSuccess
        case signOutFail(error: Error)
        case deleteAccountStart
        case deleteAccountStartConfirm
        case deleteAccountSuccess
        case deleteAccountFail(error: Error)
        case createAccountPressed
        case contactUsPressed
        case ratingsPressed
        case ratingsYesPressed
        case ratingsNoPressed
        
        var eventName: String {
            switch self {
            case .signOutStart:                 return "SettingsView_SignOut_Start"
            case .signOutSuccess:               return "SettingsView_SignOut_Success"
            case .signOutFail:                  return "SettingsView_SignOut_Fail"
            case .deleteAccountStart:           return "SettingsView_DeleteAccount_Start"
            case .deleteAccountStartConfirm:    return "SettingsView_DeleteAccount_StartConfirm"
            case .deleteAccountSuccess:         return "SettingsView_DeleteAccount_Success"
            case .deleteAccountFail:            return "SettingsView_DeleteAccount_Fail"
            case .createAccountPressed:         return "SettingsView_CreateAccount_Pressed"
            case .contactUsPressed:             return "SettingsView_ContactUs_Pressed"
            case .ratingsPressed:               return "SettingsView_Ratings_Pressed"
            case .ratingsYesPressed:            return "SettingsView_RatingsYes_Pressed"
            case .ratingsNoPressed:             return "SettingsView_RatingsNo_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .signOutFail(error: let error), .deleteAccountFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .signOutFail, .deleteAccountFail:
                return .severe
            default:
                return .analytic
            }
        }
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
    SettingsView()
        .environment(AuthManager(service: MockAuthService(user: nil)))
        .environment(UserManager(services: MockUserServices(user: nil)))
        .previewEnvironment()
}
#Preview("Anonymous") {
    SettingsView()
        .environment(AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: true))))
        .environment(UserManager(services: MockUserServices(user: .mock)))
        .previewEnvironment()
}
#Preview("Not anonymous") {
    SettingsView()
        .environment(AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: false))))
        .environment(UserManager(services: MockUserServices(user: .mock)))
        .previewEnvironment()
}
