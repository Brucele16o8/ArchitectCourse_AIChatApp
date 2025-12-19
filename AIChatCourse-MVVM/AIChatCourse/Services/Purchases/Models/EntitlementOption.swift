//
//  EntitlementOption.swift
//  AIChatCourse
//
//  Created by Tung Le on 26/11/2025.
//

enum EntitlementOption: Codable, CaseIterable {
    case yearly
    
    var productId: String {
        switch self {
        case .yearly:
            return "brucele.tt.168.AIChatCourse.yearly"
        }
    }
    
    static var allProductIds: [String] {
        EntitlementOption.allCases.map { $0.productId }
    }
}
