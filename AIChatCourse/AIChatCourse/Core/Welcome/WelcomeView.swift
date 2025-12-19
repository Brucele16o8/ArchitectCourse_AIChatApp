//
//  WelcomeView.swift
//  AIChatCourse
//
//  Created by Tung Le on 1/10/2025.
//

import SwiftUI

struct WelcomeView: View {
    
    @Environment(AppState.self) private var root
    @Environment(LogManager.self) private var logManager
    
    @State var imageName: String = Constants.randomImage
    @State private var showSignInView: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                ImageLoaderView(urlString: imageName)
                    .ignoresSafeArea()
                
                titleSection
                    .padding(24)
                
                ctaButton
                    .padding(16)
                
                policyLinks
            }
        }
        .screenAppearAnalytics(name: "WelcomeView")
        .sheet(isPresented: $showSignInView) {
            CreateAccountView(
                title: "Sign In",
                subtitle: "Connect to an existing account.",
                onDidSignIn: { isNewUser in
                    handleDidSignIn(isNewUser: isNewUser)
                }
            )
                .presentationDetents([.medium])
        }
    }
    
    // MARK: Events
    enum Event: LoggableEvent {
        case didSignIn(isNewUser: Bool)
        case signInPressed
        
        var eventName: String {
            switch self {
            case .didSignIn:               return "WelcomeView_DidSignIn"
            case .signInPressed:           return "WelcomeView_SignIn_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            default:
                return .analytic
            }
        }
    }
    
    // MARK: Helper - View
    /// 🧩
    private var titleSection: some View {
        VStack {
            Text("AI Chat 🤙")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            
            Text("Youtube @ Swiftful Thinking")
                .font(.callout)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
    }
    
    /// 🧩
    private func handleDidSignIn(isNewUser: Bool) {
        logManager.trackEvent(event: Event.didSignIn(isNewUser: isNewUser))
        
        if isNewUser {
            /// Do nothing, user goes through onboarding
        } else {
            /// Push into the tabbar View
            root.updateViewState(showTabBarView: true)
        }
    }
    
    /// 🧩
    private var ctaButton: some View {
        VStack(spacing: 8) {
            NavigationLink {
                OnboardingIntroView()
            } label: {
                Text("Get Started")
                    .callToActionButton()
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .accessibilityIdentifier("StartButton")
            .frame(maxWidth: 500)
            
            Text("Already have an account? Sign in!")
                .font(.body)
                .underline()
                .padding(8) /// increase the tappable areas
                .tappableBackground()
                .onTapGesture {
                    onSignInPressed()
                }
                .lineLimit(1)
                .minimumScaleFactor(0.3)
        }
    }
    
    /// 🧩
    private var policyLinks: some View {
        HStack(spacing: 8) {
            Link(destination: URL(string: Constants.privacyPolicyUrl)!) {
                Text("Terms of Service")
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            Circle()
                .fill(.accent)
                .frame(width: 4, height: 4)
            Link(destination: URL(string: Constants.termsOfServiceUrl)!) {
                Text("Privacy Policy")
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
        }
    }
    
    // MARK: - Helper func
    private func onSignInPressed() {
        showSignInView = true
        logManager.trackEvent(event: Event.signInPressed)
    }

} // 🧱

#Preview {
    WelcomeView()
        .previewEnvironment()
}
