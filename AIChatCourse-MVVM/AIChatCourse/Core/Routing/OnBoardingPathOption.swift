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
    
    @Environment(DependencyContainer.self) private var container
    
    let path: Binding<[OnBoardingPathOption]>
    
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: OnBoardingPathOption.self) { newValue in
                switch newValue {
                case .colorView:
                    OnboardingColorView(viewModel: OnboardingColorViewModel(interactor: CoreInteractor(container: container)), path: path)
                case .communityView:
                    OnboardingCommunityView(viewModel: OnboardingCommunityViewModel(interactor: CoreInteractor(container: container)), path: path)
                case .introView:
                    OnboardingIntroView(viewModel: OnboardingIntroViewModel(interactor: CoreInteractor(container: container)), path: path)
                case .completedView(selectedColor: let selectedColor):
                    OnboardingCompletedView(
                        viewModel: OnboardingCompletedViewModel(interactor: CoreInteractor(container: container)),
                        selectedColor: selectedColor
                    )
                }
            }
    }
}

extension View {
    func navigationDestinationForOnBoaringModule(path: Binding<[OnBoardingPathOption]>) -> some View {
        modifier(NavDesForOnBoardingModuleModifier(path: path))
    }
    
}
