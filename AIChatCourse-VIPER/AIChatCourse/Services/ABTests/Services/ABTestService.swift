//
//  ABTestService.swift
//  AIChatCourse
//
//  Created by Tung Le on 25/11/2025.
//
import Foundation

@MainActor
protocol ABTestService: Sendable {
    var activeTests: ActiveABTests { get }
    func saveUpdatedConfig(updatedTests: ActiveABTests) throws
    func fetchUpdatedConfig() async throws -> ActiveABTests
}
