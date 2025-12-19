//
//  DependencyContainer.swift
//  AIChatCourse
//
//  Created by Tung Le on 16/12/2025.
//
import SwiftUI

@Observable
@MainActor
class DependencyContainer {
    
    private var services: [String: Any] = [:]
    
    func register<T>(_ type: T.Type, service: T) {
        let key = "\(type)"
        services[key] = service
    }
    
    func register<T>(_ type: T.Type, service: () -> T) {
        let key = "\(type)"
        services[key] = service()
    }
    
    func resolve<T>(_ type: T.Type) -> T? {
        let key = "\(type)"
        return services[key] as? T
    }
}
