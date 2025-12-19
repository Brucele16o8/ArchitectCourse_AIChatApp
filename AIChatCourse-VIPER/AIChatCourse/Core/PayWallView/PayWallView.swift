//
//  PayWallView.swift
//  AIChatCourse
//
//  Created by Tung Le on 26/11/2025.
//

import SwiftUI
import StoreKit

struct PayWallView: View {
    
    @State var viewModel: PayWallViewModel

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            switch viewModel.paywallTest {
            case .custom:
                if viewModel.products.isEmpty {
                    ProgressView()
                } else {
                    CustomPaywallView(
                        products: viewModel.products,
                        onBackButtonPressed: {
                            viewModel.onBackButtonPressed(onDismiss: {
                                dismiss()
                            })
                        },
                        onRestorePurchasesPressed: {
                            viewModel.onRestorePurchasesPressed(onDismiss: {
                                dismiss()
                            })
                        },
                        onPurchaseProductPressed: { product in
                            viewModel.onPurchaseProductPressed(product: product, onDismiss: {
                                dismiss()
                            })
                        }
                    )
                }
            case .revenueCat:
                RevenueCatPayWallView()
            case .storeKit:
                StoreKitPaywallView(
                    productIds: viewModel.productIds,
                    onInAppPurchaseStart: viewModel.onPurchaseStart,
                    onInAppPurchaseCompletion: { (product, result) in
                        viewModel.onPurchaseComplete(product: product, result: result, onDismiss: {
                            dismiss()
                        })
                    }
                )
            }
        }
        .screenAppearAnalytics(name: "Paywall")
        .showCustomAlert(alert: $viewModel.showAlert)
        .task {
            await viewModel.onLoadProducts()
        }
    }
}

#Preview("Custom") {
    let container = DevPreview.shared.container
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(paywallTest: .custom)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    
    return builder
        .payWallView()
        .previewEnvironment()
}

#Preview("StoreKit") {
    let container = DevPreview.shared.container
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(paywallTest: .storeKit)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    
    return builder
        .payWallView()
        .previewEnvironment()
}

#Preview("RevenueCat") {
    let container = DevPreview.shared.container
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(paywallTest: .revenueCat)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    
    return builder
        .payWallView()
        .previewEnvironment()
}
