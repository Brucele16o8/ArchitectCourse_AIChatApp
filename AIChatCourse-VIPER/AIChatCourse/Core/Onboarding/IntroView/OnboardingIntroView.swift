//
//  OnboardingIntroView.swift
//  AIChatCourse
//
//  Created by Tung Le on 1/10/2025.
//

import SwiftUI

struct OnboardingIntroDelegate {
    var path: Binding<[OnBoardingPathOption]>
}

struct OnboardingIntroView: View {
    
    @State var viewModel: OnboardingIntroViewModel
    
    let delegate: OnboardingIntroDelegate
    
    var body: some View {
        VStack {
            Group {
                Text("Make your own ")
                +
                Text("avatars ")
                    .foregroundStyle(.accent)
                    .fontWeight(.semibold)
                +
                Text("and chat with them!\n\nHave ")
                +
                Text("real conversations ")
                    .foregroundStyle(.accent)
                    .fontWeight(.semibold)
                +
                Text("with AI generated repsonses.")
            }
            .baselineOffset(6)
            .minimumScaleFactor(0.5)
            .frame(maxHeight: .infinity)
            .padding(24)
            
            /// Button
            Text("Continue")
                .callToActionButton()
                .anyButton(.press) {
                    viewModel.onContinueButtonPressed(path: delegate.path)
                }
            .accessibilityIdentifier("ContinueButton")
        }
        .padding(24)
        .font(.title3)
        .toolbar(.hidden, for: .navigationBar)
        .screenAppearAnalytics(name: "OnboardingIntroView")
    }
}

#Preview("Original") {
    let container = DevPreview.shared.container
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    
    return NavigationStack {
        builder
            .onboardingIntroView(delegate: OnboardingIntroDelegate(path: .constant([])))
    }
    .previewEnvironment()
}

#Preview("Onb Community Test") {
    let container = DevPreview.shared.container
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(onboardingCommunityTest: true)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    
    return NavigationStack {
        builder
            .onboardingIntroView(delegate: OnboardingIntroDelegate(path: .constant([])))
    }
    .previewEnvironment()
}
