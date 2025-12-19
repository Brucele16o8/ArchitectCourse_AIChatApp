//
//  OnboardingCommunityViewModel.swift
//  AIChatCourse
//
//  Created by Tung Le on 15/12/2025.
//
import SwiftUI

@MainActor
protocol OnboardingCommunityInteractor { }

extension CoreInteractor: OnboardingCommunityInteractor { }

@Observable
@MainActor
class OnboardingCommunityViewModel {
    let interactor: OnboardingCommunityInteractor
    
    init(interactor: OnboardingCommunityInteractor) {
        self.interactor = interactor
    }
    
    // MARK: - Methods
    func onContinueButtonPressed(path: Binding<[OnBoardingPathOption]>) {
        path.wrappedValue.append(.colorView)
    }
}
