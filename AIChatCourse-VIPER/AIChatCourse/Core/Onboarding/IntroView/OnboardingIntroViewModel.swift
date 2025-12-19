//
//  OnboardingIntroViewModel.swift
//  AIChatCourse
//
//  Created by Tung Le on 15/12/2025.
//
import SwiftUI

@MainActor
protocol OnboardingIntroInteractor {
    var onboardingCommunityTest: Bool { get }
    
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingIntroInteractor { }

@Observable
@MainActor
class OnboardingIntroViewModel {
    let interactor: OnboardingIntroInteractor
    
    init(interactor: OnboardingIntroInteractor) {
        self.interactor = interactor
    }
    
    // MARK: - Methods
    func onContinueButtonPressed(path: Binding<[OnBoardingPathOption]>) {
        if interactor.onboardingCommunityTest {
            path.wrappedValue.append(.communityView)
        } else {
            path.wrappedValue.append(.colorView)
        }
    }
}
