//
//  OnboardingCompletedView.swift
//  AIChatCourse
//
//  Created by Tung Le on 1/10/2025.
//

import SwiftUI

struct OnboardingCompletedDelegate {
    var selectedColor: Color = .orange
}

struct OnboardingCompletedView: View {
    
    @State var viewModel: OnboardingCompletedViewModel
    
    var delegate: OnboardingCompletedDelegate = OnboardingCompletedDelegate()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Setup Complete!")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundStyle(delegate.selectedColor)
            
            Text("We've set up your profile and you're ready to start chatting.")
                .font(.title)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
        .frame(maxHeight: .infinity)
        .safeAreaInset(edge: .bottom, alignment: .center, spacing: 16) {
            AsyncCallToActionButton(
                isLoading: viewModel.isCompletingProfileSetup,
                title: "Finish",
                action: {
                    viewModel.onFinishButtonPressed(selectedColor: delegate.selectedColor)
                }
            )
            .accessibilityIdentifier("FinishButton")
        }
        .padding(24)
        .toolbar(.hidden, for: .navigationBar)
        .screenAppearAnalytics(name: "OnboardingCompletedView")
        .showCustomAlert(alert: $viewModel.showAlert)
    }

} // 🧱

#Preview {
    let container = DevPreview.shared.container
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = OnboardingCompletedDelegate(selectedColor: .mint)
    
    return builder
        .onboardingCompletedView(delegate: delegate)
        .environment(container)
        .previewEnvironment()
}
