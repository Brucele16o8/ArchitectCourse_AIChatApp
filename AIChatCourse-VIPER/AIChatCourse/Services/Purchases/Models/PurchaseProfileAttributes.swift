//
//  PurchaseProfileAttributes.swift
//  AIChatCourse
//
//  Created by Tung Le on 30/11/2025.
//
import Foundation

struct PurchaseProfileAttributes {
    let email: String?
    let firebaseAppInstanceId: String?
    let mixpanelDistinctId: String?
    
    init(
        email: String? = nil,
        firebaseAppInstanceId: String? = nil,
        mixpanelDistinctId: String? = nil
    ) {
        self.email = email
        self.firebaseAppInstanceId = firebaseAppInstanceId
        self.mixpanelDistinctId = mixpanelDistinctId
    }
}
