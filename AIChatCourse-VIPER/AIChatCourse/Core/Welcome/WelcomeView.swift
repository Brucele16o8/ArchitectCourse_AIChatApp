//
//  WelcomeView.swift
//  AIChatCourse
//
//  Created by Tung Le on 1/10/2025.
//

import SwiftUI

struct WelcomeView: View {
        
    @State var viewModel: WelcomeViewModel
    
    @ViewBuilder var createAccountView: (CreateAccountDelegate) -> AnyView
    @ViewBuilder var onboardingColorView: (OnboardingColorDelegate) -> AnyView
    @ViewBuilder var onboardingCommunityView: (OnboardingCommunityDelegate) -> AnyView
    @ViewBuilder var onboardingIntroView: (OnboardingIntroDelegate) -> AnyView
    @ViewBuilder var onboardingCompletedView: (OnboardingCompletedDelegate) -> AnyView
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            VStack(spacing: 8) {
                ImageLoaderView(urlString: viewModel.imageName)
                    .ignoresSafeArea()
                
                titleSection
                    .padding(24)
                
                ctaButton
                    .padding(16)
                
                policyLinks
            }
            .navigationDestinationForOnBoaringModule(
                path: $viewModel.path,
                onboardingColorView: onboardingColorView,
                onboardingCommunityView: onboardingCommunityView,
                onboardingIntroView: onboardingIntroView,
                onboardingCompletedView: onboardingCompletedView
            )
        }
        .screenAppearAnalytics(name: "WelcomeView")
        .sheet(isPresented: $viewModel.showSignInView) {
            createAccountView(
                CreateAccountDelegate(
                    title: "Sign In",
                    subtitle: "Connect to an existing account.",
                    onDidSignIn: { isNewUser in
                        viewModel.handleDidSignIn(isNewUser: isNewUser)
                    }
                )
            )
            .presentationDetents([.medium])
        }
    }
    
    // MARK: - Subviews
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
    
    private var ctaButton: some View {
        VStack(spacing: 8) {
            Text("Get Started")
                .callToActionButton()
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .anyButton(.press) {
                    viewModel.onGetStartedPressed()
                }
                .accessibilityIdentifier("StartButton")
                .frame(maxWidth: 500)
            
            Text("Already have an account? Sign in!")
                .font(.body)
                .underline()
                .padding(8) /// increase the tappable areas
                .tappableBackground()
                .onTapGesture {
                    viewModel.onSignInPressed()
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
} // 🧱

#Preview {
    let container = DevPreview.shared.container
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    
    return builder
        .welcomeView()
        .previewEnvironment()
}
