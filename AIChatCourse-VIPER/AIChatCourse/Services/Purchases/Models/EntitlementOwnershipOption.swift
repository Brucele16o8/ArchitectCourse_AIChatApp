//
//  EntitlementOwnershipOption.swift
//  AIChatCourse
//
//  Created by Tung Le on 25/11/2025.
//
import Foundation

public enum EntitlementOwnershipOption: Codable, Sendable {
    case purchased, familyShared, unknown
}

import StoreKit

extension EntitlementOwnershipOption {
    
    init(type: StoreKit.Transaction.OwnershipType) {
        switch type {
        case .purchased:
            self = .purchased
        case .familyShared:
            self = .familyShared
        default:
            self = .unknown
        }
    }
}
