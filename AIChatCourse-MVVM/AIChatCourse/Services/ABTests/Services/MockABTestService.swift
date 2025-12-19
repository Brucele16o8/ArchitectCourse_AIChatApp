//
//  MockABTestService.swift
//  AIChatCourse
//
//  Created by Tung Le on 25/11/2025.
//
import SwiftUI

@MainActor
class MockABTestService: ABTestService {
    var activeTests: ActiveABTests
    
    init(
        createAccountTest: Bool? = nil,
        onboardingCommunityTest: Bool? = nil,
        categoryRowTest: CategoryRowTestOption? = nil,
        paywallTest: PaywallTestOption? = nil
    ) {
        self.activeTests = ActiveABTests(
            createAccountTest: createAccountTest ?? false,
            onboardingCommunityTest: onboardingCommunityTest ?? false,
            categoryRowTest: categoryRowTest ?? .default,
            paywallTest: paywallTest ?? .default
        )
    }
    
    func saveUpdatedConfig(updatedTests: ActiveABTests) throws {
        activeTests = updatedTests
    }
    
    func fetchUpdatedConfig() async throws -> ActiveABTests {
        activeTests
    }
}
