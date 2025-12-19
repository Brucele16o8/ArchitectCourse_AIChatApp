//
//  OnboardingColorViewModel.swift
//  AIChatCourse
//
//  Created by Tung Le on 15/12/2025.
//
import SwiftUI

@MainActor
protocol OnboardingColorInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingColorInteractor { }

@Observable
@MainActor
class OnboardingColorViewModel {
    let interactor: OnboardingColorInteractor
    
    let profileColors: [Color] = [.red, .green, .orange, .blue, .mint, .purple, .cyan, .teal, .indigo]
    private(set) var selectedColor: Color?
    
    init(interactor: OnboardingColorInteractor) {
        self.interactor = interactor
    }
    
    // MARK: - Methods
    func onColorPressed(color: Color) {
        selectedColor = color
    }
    
    func onContinueButtonPressed(path: Binding<[OnBoardingPathOption]>) {
        guard let selectedColor else { return }
        path.wrappedValue.append(.completedView(selectedColor: selectedColor))
    }
}
