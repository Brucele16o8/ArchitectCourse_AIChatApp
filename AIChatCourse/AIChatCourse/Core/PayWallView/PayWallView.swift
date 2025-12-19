//
//  PayWallView.swift
//  AIChatCourse
//
//  Created by Tung Le on 26/11/2025.
//

import SwiftUI
import StoreKit

struct PayWallView: View {    
    
    @Environment(PurchaseManager.self) private var purchaseManager
    @Environment(LogManager.self) private var logManager
    @Environment(ABTestManager.self) private var abTestManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var products: [AnyProduct] = []
    @State private var productIds: [String] = EntitlementOption.allProductIds
    @State private var showAlert: AnyAppAlert?
    
    var body: some View {
        ZStack {
            switch abTestManager.activeTests.paywallTest {
            case .custom:
                if products.isEmpty {
                    ProgressView()
                } else {
                    CustomPaywallView(
                        products: products,
                        onBackButtonPressed: onBackButtonPressed,
                        onRestorePurchasesPressed: onRestorePurchasesPressed,
                        onPurchaseProductPressed: onPurchaseProductPressed
                    )
                }
            case .revenueCat:
                RevenueCatPayWallView()
            case .storeKit:
                StoreKitPaywallView(
                    productIds: productIds,
                    onInAppPurchaseStart: onPurchaseStart,
                    onInAppPurchaseCompletion: onPurchaseComplete
                )
            }
        }
        .screenAppearAnalytics(name: "Paywall")
        .showCustomAlert(alert: $showAlert)
        .task {
            await onLoadProducts()
        }
    }
    
    // MARK: - Methods
    private func onLoadProducts() async {
        do {
            products = try await purchaseManager.getProducts(productIds: productIds)
        } catch {
            showAlert = AnyAppAlert(error: error)
        }
    }
    
    private func onBackButtonPressed() {
        logManager.trackEvent(event: Event.backButtonPressed)
        dismiss()
    }
    
    private func onRestorePurchasesPressed() {
        logManager.trackEvent(event: Event.restorePurchaseStart)
        
        Task {
            do {
                let entitlements = try await purchaseManager.restorePurchase()
                
                if entitlements.hasActiveEntitlement {
                    dismiss()
                }
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
    private func onPurchaseProductPressed(product: AnyProduct) {
        logManager.trackEvent(event: Event.purchaseStart(product: product))
        
        Task {
            do {
                let entitlements = try await purchaseManager.purchaseProduct(productId: product.id)
                logManager.trackEvent(event: Event.purchaseSuccess(product: product))
                
                if entitlements.hasActiveEntitlement {
                    dismiss()
                }
            } catch {
                logManager.trackEvent(event: Event.purchaseFail(error: error))
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
    // MARK: - Methods
    private func onPurchaseStart(product: StoreKit.Product) {
        let product = AnyProduct(storeKitProduct: product)
        logManager.trackEvent(event: Event.purchaseStart(product: product))
    }
    
    private func onPurchaseComplete(product: Product, result: Result<Product.PurchaseResult, any Error>) {
        let product = AnyProduct(storeKitProduct: product)
        
        switch result {
        case .success(let value):
            switch value {
            case .success:
                logManager.trackEvent(event: Event.purchaseSuccess(product: product))
                dismiss()
            case .pending:
                logManager.trackEvent(event: Event.purchasePending(product: product))
            case .userCancelled:
                logManager.trackEvent(event: Event.purchaseCancelled(product: product))
            default:
                logManager.trackEvent(event: Event.purchaseUnknown(product: product))
            }
        case .failure(let error):
            logManager.trackEvent(event: Event.purchaseFail(error: error))
        }
    }
    
    // MARK: - Events
    enum Event: LoggableEvent {
        case purchaseStart(product: AnyProduct)
        case purchaseSuccess(product: AnyProduct)
        case purchasePending(product: AnyProduct)
        case purchaseCancelled(product: AnyProduct)
        case purchaseUnknown(product: AnyProduct)
        case purchaseFail(error: Error)
        case loadProductStart
        case restorePurchaseStart
        case backButtonPressed
        
        var eventName: String {
            switch self {
            case .purchaseStart:               return "Paywall_Purchase_Start"
            case .purchaseSuccess:             return "Paywall_Purchase_Success"
            case .purchasePending:             return "Paywall_Purchase_Pending"
            case .purchaseCancelled:           return "Paywall_Purchase_Cancelled"
            case .purchaseUnknown:             return "Paywall_Purchase_Unknown"
            case .purchaseFail:                return "Paywall_Purchase_Fail"
            case .loadProductStart:            return "Paywall_Load_Start"
            case .restorePurchaseStart:        return "Paywall_Restore_Start"
            case .backButtonPressed:           return "Paywall_BackButton_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .purchaseStart(product: let product), .purchaseSuccess(product: let product), .purchasePending(product: let product), .purchaseCancelled(product: let product), .purchaseUnknown(product: let product):
                return product.eventParameters
            case .purchaseFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .purchaseFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}

#Preview("Custom") {
    PayWallView()
        .environment(ABTestManager(service: MockABTestService(paywallTest: .custom)))
        .previewEnvironment()
}

#Preview("StoreKit") {
    PayWallView()
        .environment(ABTestManager(service: MockABTestService(paywallTest: .storeKit)))
        .previewEnvironment()
}

#Preview("RevenueCat") {
    PayWallView()
        .environment(ABTestManager(service: MockABTestService(paywallTest: .revenueCat)))
        .previewEnvironment()
}
