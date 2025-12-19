//
//  WelcomeViewModel.swift
//  AIChatCourse
//
//  Created by Tung Le on 14/12/2025.
//
import SwiftUI

@MainActor
protocol WelcomeInteractor {
    func trackEvent(event: LoggableEvent)
    func updateAppState(showTabBarView: Bool)
}

extension CoreInteractor: WelcomeInteractor { }

@Observable
@MainActor
class WelcomeViewModel {
    let interactor: WelcomeInteractor
        
    private(set) var imageName: String = Constants.randomImage
    
    var showSignInView: Bool = false
    var path: [OnBoardingPathOption] = []
    
    init(interactor: WelcomeInteractor) {
        self.interactor = interactor
    }
    
    // MARK: - Methods
    func onGetStartedPressed() {
        path.append(.introView)
    }
    
    func onSignInPressed() {
        showSignInView = true
        interactor.trackEvent(event: Event.signInPressed)
    }
    
    func handleDidSignIn(isNewUser: Bool) {
        interactor.trackEvent(event: Event.didSignIn(isNewUser: isNewUser))
        
        if isNewUser {
            /// Do nothing, user goes through onboarding
        } else {
            /// Push into the tabbar View
            interactor.updateAppState(showTabBarView: true)
        }
    }

    // MARK: Events
    enum Event: LoggableEvent {
        case didSignIn(isNewUser: Bool)
        case signInPressed
        
        var eventName: String {
            switch self {
            case .didSignIn:               return "WelcomeView_DidSignIn"
            case .signInPressed:           return "WelcomeView_SignIn_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            default:
                return .analytic
            }
        }
    }
}
