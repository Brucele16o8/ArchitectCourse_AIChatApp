//
//  OnboardingCompletedViewModel.swift
//  AIChatCourse
//
//  Created by Tung Le on 15/12/2025.
//
import SwiftUI

@MainActor
protocol OnboardingCompletedInteractor {
    func trackEvent(event: LoggableEvent)
    func markOnboardingCompleted(profileColorHex: String) async throws
    func updateAppState(showTabBarView: Bool)
}

extension CoreInteractor: OnboardingCompletedInteractor { }

@Observable
@MainActor
class OnboardingCompletedViewModel {
    
    let interactor: OnboardingCompletedInteractor
    
    private(set) var isCompletingProfileSetup: Bool = false
    var showAlert: AnyAppAlert?
    
    init(interactor: OnboardingCompletedInteractor) {
        self.interactor = interactor
    }
    
    // MARK: - Methods
    func onFinishButtonPressed(selectedColor: Color) {
        isCompletingProfileSetup = true
        interactor.trackEvent(event: Event.finishStart)
        
        Task {
            do {
                let hex = selectedColor.toHex() ?? Constants.accentColorHex
                try await interactor.markOnboardingCompleted(profileColorHex: hex)
                interactor.trackEvent(event: Event.finishSuccess(hex: hex))
                
                /// dismiss screen
                isCompletingProfileSetup = false
                
                /// Show tabbar view
                interactor.updateAppState(showTabBarView: true)
            } catch {
                showAlert = AnyAppAlert(error: error)
                interactor.trackEvent(event: Event.finishFail(error: error))
            }
        }
    }
    
    // MARK: - Events
    enum Event: LoggableEvent {
        case finishStart
        case finishSuccess(hex: String)
        case finishFail(error: Error)
        
        var eventName: String {
            switch self {
            case .finishStart:        return "OnboardingCompletedView_Finish_Start"
            case .finishSuccess:      return "OnboardingCompletedView_Finish_Success"
            case .finishFail:         return "OnboardingCompletedView_Finish_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .finishSuccess(hex: let hex):
                return [
                    "profile_color_hex": hex
                ]
            case .finishFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .finishFail:
                return .severe
            default:
                return .analytic
            }
        }
    }

}
