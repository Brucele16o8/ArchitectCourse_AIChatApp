//
//  PurchaseService.swift
//  AIChatCourse
//
//  Created by Tung Le on 30/11/2025.
//
import SwiftUI

protocol PurchaseService: Sendable {
    func listenForTransaction(onTransactionUpdated: ([PurchasedEntitlement]) async -> Void) async
    func getUserEntitlements() async throws -> [PurchasedEntitlement]
    func getProducts(productIds: [String]) async throws -> [AnyProduct]
    func restorePurchase() async throws -> [PurchasedEntitlement]
    func purchaseProduct(productId: String) async throws -> [PurchasedEntitlement]
    func login(userId: String) async throws -> [PurchasedEntitlement]
    func updateProfileAttributes(attributes: PurchaseProfileAttributes) async throws
    func logOut() async throws
}
