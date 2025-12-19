//
//  FirebaseABTestService.swift
//  AIChatCourse
//
//  Created by Tung Le on 25/11/2025.
//
import FirebaseRemoteConfig
import SwiftUI

@MainActor
class FirebaseABTestService: ABTestService {
    
    var activeTests: ActiveABTests {
        ActiveABTests(config: RemoteConfig.remoteConfig())
    }
    
    init() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        RemoteConfig.remoteConfig().configSettings = settings
        
        let defaultValues = ActiveABTests(
            createAccountTest: false,
            onboardingCommunityTest: false,
            categoryRowTest: .default,
            paywallTest: .default
        )
        
        RemoteConfig.remoteConfig().setDefaults(defaultValues.asNSObjectDictionary)
        RemoteConfig.remoteConfig().activate()
    }
    
    func saveUpdatedConfig(updatedTests: ActiveABTests) throws {
        assertionFailure("Error: Firebase AB Tests are not configurable from the client.")
    }
    
    func fetchUpdatedConfig() async throws -> ActiveABTests {
        let status = try await RemoteConfig.remoteConfig().fetchAndActivate()
        
        switch status {
        case .successFetchedFromRemote, .successUsingPreFetchedData:
            return activeTests
        case .error:
            throw RemoteConfigError.failedToFetch
        default:
            throw RemoteConfigError.failedToFetch
        }
        
    }
    
    // MARK: - Types
    enum RemoteConfigError: LocalizedError {
        case failedToFetch
    }
} // 🧱
