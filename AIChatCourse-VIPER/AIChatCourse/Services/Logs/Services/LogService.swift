//
//  LogService.swift
//  AIChatCourse
//
//  Created by Tung Le on 9/11/2025.
//
import Foundation

protocol LogService {
    func identifyUser(userId: String, name: String?, email: String?)
    func addUserProperties(dict: [String: Any], isHighPriority: Bool)
    func deleteUserProfile()
    
    func trackEvent(event: LoggableEvent)
    func trackScreenEvent(event: LoggableEvent)
} // 🧱
