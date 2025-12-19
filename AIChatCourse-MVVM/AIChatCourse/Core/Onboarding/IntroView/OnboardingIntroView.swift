//
//  OnboardingIntroView.swift
//  AIChatCourse
//
//  Created by Tung Le on 1/10/2025.
//

import SwiftUI

struct OnboardingIntroView: View {
    
    @State var viewModel: OnboardingIntroViewModel
    
    @Environment(DependencyContainer.self) private var container
    @Binding var path: [OnBoardingPathOption]
    
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
                    viewModel.onContinueButtonPressed(path: $path)
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
    
    return NavigationStack {
        OnboardingIntroView(
            viewModel: OnboardingIntroViewModel(interactor: CoreInteractor(container: container)),
            path: .constant([])
        )
    }
    .environment(container)
    .previewEnvironment()
}

#Preview("Onb Community Test") {
    let container = DevPreview.shared.container
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(onboardingCommunityTest: true)))
    
    return NavigationStack {
        OnboardingIntroView(
            viewModel: OnboardingIntroViewModel(interactor: CoreInteractor(container: container)),
            path: .constant([])
        )
    }
    .environment(container)
    .previewEnvironment()
}
