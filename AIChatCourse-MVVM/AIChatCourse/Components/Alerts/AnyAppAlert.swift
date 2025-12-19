//
//  AnyAppAlert.swift
//  AIChatCourse
//
//  Created by Tung Le on 15/10/2025.
//
import SwiftUI
import Foundation

struct AnyAppAlert: Sendable {
    var title: String
    var subtitle: String?
    var buttons: @Sendable () -> AnyView
    
    init(
        title: String,
        subtitle: String? = nil,
        buttons: (@Sendable () -> AnyView)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.buttons = buttons ?? {
            AnyView(
                Button("OK") { }
            )
        }
    }
    
    init(error: Error) {
        self.init(title: "Error", subtitle: error.localizedDescription, buttons: nil)
    }
    
} /// 🧱

enum AlertType {
    case alert, confirmationDiaglog
}

extension View {
    
    @ViewBuilder
    func showCustomAlert(type: AlertType = .alert, alert: Binding<AnyAppAlert?>) -> some View {
        switch type {
        case .alert:
            self
                .alert(alert.wrappedValue?.title ?? "", isPresented: Binding(ifNotNil: alert)) {
                    alert.wrappedValue?.buttons()
                } message: {
                    if let subtitle = alert.wrappedValue?.subtitle {
                        Text(subtitle)
                    }
                }
        case .confirmationDiaglog:
            self
                .confirmationDialog(alert.wrappedValue?.title ?? "", isPresented: Binding(ifNotNil: alert)) {
                    alert.wrappedValue?.buttons()
                } message: {
                    Text("What would you like to do?")
                }
        }
    }
    
} /// 🧱
