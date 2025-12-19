//
//  PaywallTestOption.swift
//  AIChatCourse
//
//  Created by Tung Le on 30/11/2025.
//
import SwiftUI

enum PaywallTestOption: String, Codable, CaseIterable {
    case storeKit, custom, revenueCat
    
    static var `default`: Self {
        .storeKit
    }
}
