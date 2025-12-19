//
//  AppViewViewModel.swift
//  AIChatCourse
//
//  Created by Tung Le on 15/12/2025.
//
import SwiftUI

@MainActor
protocol AppViewInteractor {
    var auth: UserAuthInfo? { get }
    var showTabbar: Bool { get }
    
    func trackEvent(event: LoggableEvent)
    func logIn(user: UserAuthInfo, isNewUser: Bool) async throws
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool)
}

extension CoreInteractor: AppViewInteractor { }

@Observable
@MainActor
class AppViewViewModel {
    private var interactor: AppViewInteractor
    var showTabbar: Bool {
        interactor.showTabbar
    }
    
    init(interactor: AppViewInteractor) {
        self.interactor = interactor
    }
    
    // MARK: Methods
    func showATPromptTIfNeeded() async {
        #if !DEBUG
        let status = await AppTrackingTransparencyHelper.requestTrackingAuthorization()
        interactor.trackEvent(event: Event.attStatus(dict: status.eventParameters))
        #endif
    }
    
    func checkUserStatus() async {
        if let user = interactor.auth {
            /// User is authenticated !!!
            interactor.trackEvent(event: Event.existingAuthStart)
            
            do {
                try await interactor.logIn(user: user, isNewUser: false)
            } catch {
                interactor.trackEvent(event: Event.existingAuthFail(error: error))
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
        } else {
            /// User is not authenticated !!!
            do {
                let result = try await interactor.signInAnonymously()
                
                /// log into app
                interactor.trackEvent(event: Event.anonAuthStart)
                
                /// Log in
                try await interactor.logIn(user: result.user, isNewUser: result.isNewUser)
            } catch {
                interactor.trackEvent(event: Event.anonAuthFail(error: error))
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
        }
    }
    
    // MARK: Events
    enum Event: LoggableEvent {
        case existingAuthStart
        case existingAuthFail(error: Error)
        case anonAuthStart
        case anonAuthSuccess
        case anonAuthFail(error: Error)
        case attStatus(dict: [String: Any])
        
        var eventName: String {
            switch self {
            case .existingAuthStart:     return "AppView_ExistingAuth_Start"
            case .existingAuthFail:      return "AppView_ExistingAuth_Fail"
            case .anonAuthStart:         return "AppView_AnonAuth_Start"
            case .anonAuthSuccess:       return "AppView_AnonAuth_Success"
            case .anonAuthFail:          return "AppView_AnonAuth_Fail"
            case .attStatus:             return "AppView_ATTStatus"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .existingAuthFail(error: let error), .anonAuthFail(error: let error):
                return error.eventParameters
            case .attStatus(dict: let dict):
                return dict
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .existingAuthFail, .anonAuthFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
