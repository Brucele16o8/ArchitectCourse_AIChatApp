//
//  RevenueCatPayWallView.swift
//  AIChatCourse
//
//  Created by Tung Le on 29/11/2025.
//

import SwiftUI
import RevenueCat
import RevenueCatUI

struct RevenueCatPayWallView: View {
    var body: some View {
        RevenueCatUI.PaywallView(displayCloseButton: true)
    }
}

#Preview {
    RevenueCatPayWallView()
}
