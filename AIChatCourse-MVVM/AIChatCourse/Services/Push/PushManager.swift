//
//  PushManager.swift
//  AIChatCourse
//
//  Created by Tung Le on 16/11/2025.
//
import Foundation
import SwiftfulUtilities

@MainActor
@Observable
class PushManager {
    
    private let logManager: LogManager?
    
    init(logManager: LogManager? = nil) {
        self.logManager = logManager
    }    
    
    // MARK: Methods
    func requestAuthorization() async throws -> Bool {
        let isAuthorized = try await LocalNotifications.requestAuthorization()
        logManager?.addUserProperties(dict: ["push_is_authorized": isAuthorized], isHighPriority: true)
        
        return isAuthorized
    }
    
    func canRequestAuthorization() async -> Bool {
        await LocalNotifications.canRequestAuthorization()
    }
    
    func schedulePushNotificationsForTheNextWeek() {
        LocalNotifications.removeAllPendingNotifications()
        LocalNotifications.removeAllDeliveredNotifications()
        
        Task {
            do {
                /// Tomorrow
                try await scheduleNotification(
                    title: "Hey you! Ready to chat?",
                    subtitle: "Open AI Chat to begin.",
                    triggerDate: Date().addingTimeInterval(days: 1)
                )
                
                /// In 3 days
                try await scheduleNotification(
                    title: "Someone sent you a message!",
                    subtitle: "Open AI Chat to respond.",
                    triggerDate: Date().addingTimeInterval(days: 3)
                )
                
                /// In 5 days
                try await scheduleNotification(
                    title: "Hey stranger. We miss you!",
                    subtitle: "Don't forget about us.",
                    triggerDate: Date().addingTimeInterval(days: 5)
                )
                
                logManager?.trackEvent(event: Event.weekScheduleSuccess)
            } catch {
                logManager?.trackEvent(event: Event.weekScheduleFail(error: error))
            }
        }
    }
    
    private func scheduleNotification(title: String, subtitle: String, triggerDate: Date) async throws {
        let content = AnyNotificationContent(title: title, body: subtitle)
        let trigger = NotificationTriggerOption.date(date: triggerDate, repeats: false)
        try await LocalNotifications.scheduleNotification(content: content, trigger: trigger)
    }
    
    // MARK: Events
    enum Event: LoggableEvent {
        case weekScheduleSuccess
        case weekScheduleFail(error: Error)
        
        var eventName: String {
            switch self {
            case .weekScheduleSuccess:            return "PushMan_WeekSchedule_Success"
            case .weekScheduleFail:               return "PushMan_WeekSchedule_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .weekScheduleFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .weekScheduleFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
    
} // 🧱
