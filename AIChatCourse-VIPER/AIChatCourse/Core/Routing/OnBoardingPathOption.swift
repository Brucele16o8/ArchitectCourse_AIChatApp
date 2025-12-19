//
//  OnBoardingPathOption.swift
//  AIChatCourse
//
//  Created by Tung Le on 15/12/2025.
//
import Foundation
import SwiftUI

enum OnBoardingPathOption: Hashable {
    case colorView
    case communityView
    case introView
    case completedView(selectedColor: Color)
}

struct NavDesForOnBoardingModuleModifier: ViewModifier {
      
    let path: Binding<[OnBoardingPathOption]>
    
    @ViewBuilder var onboardingColorView: (OnboardingColorDelegate) -> AnyView
    @ViewBuilder var onboardingCommunityView: (OnboardingCommunityDelegate) -> AnyView
    @ViewBuilder var onboardingIntroView: (OnboardingIntroDelegate) -> AnyView
    @ViewBuilder var onboardingCompletedView: (OnboardingCompletedDelegate) -> AnyView
    
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: OnBoardingPathOption.self) { newValue in
                switch newValue {
                case .colorView:
                    onboardingColorView(OnboardingColorDelegate(path: path))
                    
                case .communityView:
                    onboardingCommunityView(OnboardingCommunityDelegate(path: path))
                    
                case .introView:
                    onboardingIntroView(OnboardingIntroDelegate(path: path))
                    
                case .completedView(selectedColor: let selectedColor):
                    onboardingCompletedView( OnboardingCompletedDelegate(selectedColor: selectedColor))
                }
            }
    }
}

extension View {
    func navigationDestinationForOnBoaringModule(
        path: Binding<[OnBoardingPathOption]>,
        @ViewBuilder onboardingColorView: @escaping (OnboardingColorDelegate) -> AnyView,
        @ViewBuilder onboardingCommunityView: @escaping (OnboardingCommunityDelegate) -> AnyView,
        @ViewBuilder onboardingIntroView: @escaping (OnboardingIntroDelegate) -> AnyView,
        @ViewBuilder onboardingCompletedView: @escaping (OnboardingCompletedDelegate) -> AnyView
        
    ) -> some View {
        modifier(
            NavDesForOnBoardingModuleModifier(
                path: path,
                onboardingColorView: onboardingColorView,
                onboardingCommunityView: onboardingCommunityView,
                onboardingIntroView: onboardingIntroView,
                onboardingCompletedView: onboardingCompletedView
            )
        )
    }
    
}
