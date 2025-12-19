//
//  PayWallViewModel.swift
//  AIChatCourse
//
//  Created by Tung Le on 14/12/2025.
//
import SwiftUI
import StoreKit

@MainActor
protocol PayWallInteractor {
    var paywallTest: PaywallTestOption { get }
    
    func trackEvent(event: LoggableEvent)
    func getProducts(productIds: [String]) async throws -> [AnyProduct]
    func restorePurchase() async throws -> [PurchasedEntitlement]
    func purchaseProduct(productId: String) async throws -> [PurchasedEntitlement]
}

extension CoreInteractor: PayWallInteractor { }

@Observable
@MainActor
class PayWallViewModel {
    let interactor: PayWallInteractor
    
    private(set) var products: [AnyProduct] = []
    private(set) var productIds: [String] = EntitlementOption.allProductIds
    
    var showAlert: AnyAppAlert?
    var paywallTest: PaywallTestOption {
        interactor.paywallTest
    }
    
    init(interactor: PayWallInteractor) {
        self.interactor = interactor
    }
    
    // MARK: - Methods
    func onLoadProducts() async {
        do {
            products = try await interactor.getProducts(productIds: productIds)
        } catch {
            showAlert = AnyAppAlert(error: error)
        }
    }
    
    func onBackButtonPressed(onDismiss: () -> Void) {
        interactor.trackEvent(event: Event.backButtonPressed)
        onDismiss()
    }
    
    func onRestorePurchasesPressed(onDismiss: @escaping () -> Void) {
        interactor.trackEvent(event: Event.restorePurchaseStart)
        
        Task {
            do {
                let entitlements = try await interactor.restorePurchase()
                
                if entitlements.hasActiveEntitlement {
                    onDismiss()
                }
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
    func onPurchaseProductPressed(product: AnyProduct, onDismiss: @escaping () -> Void) {
        interactor.trackEvent(event: Event.purchaseStart(product: product))
        
        Task {
            do {
                let entitlements = try await interactor.purchaseProduct(productId: product.id)
                interactor.trackEvent(event: Event.purchaseSuccess(product: product))
                
                if entitlements.hasActiveEntitlement {
                    onDismiss()
                }
            } catch {
                interactor.trackEvent(event: Event.purchaseFail(error: error))
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
    func onPurchaseStart(product: StoreKit.Product) {
        let product = AnyProduct(storeKitProduct: product)
        interactor.trackEvent(event: Event.purchaseStart(product: product))
    }
    
    func onPurchaseComplete(product: Product, result: Result<Product.PurchaseResult, any Error>, onDismiss: @escaping () -> Void) {
        let product = AnyProduct(storeKitProduct: product)
        
        switch result {
        case .success(let value):
            switch value {
            case .success:
                interactor.trackEvent(event: Event.purchaseSuccess(product: product))
                onDismiss()
            case .pending:
                interactor.trackEvent(event: Event.purchasePending(product: product))
            case .userCancelled:
                interactor.trackEvent(event: Event.purchaseCancelled(product: product))
            default:
                interactor.trackEvent(event: Event.purchaseUnknown(product: product))
            }
        case .failure(let error):
            interactor.trackEvent(event: Event.purchaseFail(error: error))
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
