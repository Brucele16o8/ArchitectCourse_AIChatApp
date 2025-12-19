//
//  OnboardingCommunityView.swift
//  AIChatCourse
//
//  Created by Tung Le on 23/11/2025.
//
import SwiftUI

struct OnboardingCommunityView: View {
    
    @State var viewModel: OnboardingCommunityViewModel
    
    @Environment(DependencyContainer.self) private var container
    @Binding var path: [OnBoardingPathOption]
    
    var body: some View {
        VStack {
            VStack(spacing: 40) {
                ImageLoaderView()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                
                Group {
                    Text("Join our community with over ")
                    +
                    Text("1000+ ")
                        .foregroundStyle(.accent)
                        .fontWeight(.semibold)
                    +
                    Text("custom avatars.\n\nAsk them questions or have a casual conversation!")
                }
                .baselineOffset(6)
                .minimumScaleFactor(0.5)
                .padding(24)
            }
            .frame(maxHeight: .infinity)
            
            /// Button
            Text("Continue")
                .callToActionButton()
                .anyButton(.press) {
                    viewModel.onContinueButtonPressed(path: $path)
                }
            .accessibilityIdentifier("OnboardingCommunityContinueButton")
        }
        .padding(24)
        .font(.title3)
        .toolbar(.hidden, for: .navigationBar)
        .screenAppearAnalytics(name: "OnboardingCommunityView")
    }
}

#Preview {
    let container = DevPreview.shared.container
    
    return NavigationStack {
        OnboardingCommunityView(
            viewModel: OnboardingCommunityViewModel(interactor: CoreInteractor(container: container)),
            path: .constant([])
        )
    }
    .previewEnvironment()
}
