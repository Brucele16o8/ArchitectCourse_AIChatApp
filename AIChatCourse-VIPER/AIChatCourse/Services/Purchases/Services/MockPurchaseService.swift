//
//  MockPurchaseService.swift
//  AIChatCourse
//
//  Created by Tung Le on 30/11/2025.
//
import SwiftUI

struct MockPurchaseService: PurchaseService {
    
    let activeEntitlements: [PurchasedEntitlement]
    
    init(activeEntitlements: [PurchasedEntitlement] = []) {
        self.activeEntitlements = activeEntitlements
    }
    
    func listenForTransaction(onTransactionUpdated: ([PurchasedEntitlement]) async -> Void) async {
        await onTransactionUpdated(activeEntitlements)
    }
    
    func getUserEntitlements() async throws -> [PurchasedEntitlement] {
        activeEntitlements
    }
    
    func getProducts(productIds: [String]) async throws -> [AnyProduct] {
        return AnyProduct.mocks.filter { product in
            return productIds.contains(product.id)
        }
    }
    
    func purchaseProduct(productId: String) async throws -> [PurchasedEntitlement] {
        activeEntitlements
    }
    
    func restorePurchase() async throws -> [PurchasedEntitlement] {
        activeEntitlements
    }
    
    func login(userId: String) async throws -> [PurchasedEntitlement] {
        activeEntitlements
    }
    
    func updateProfileAttributes(attributes: PurchaseProfileAttributes) async throws {
        
    }
    
    func logOut() async throws {
        
    }
    
}
