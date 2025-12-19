//
//  ButtonViewModifier.swift
//  AIChatCourse
//
//  Created by Tung Le on 13/10/2025.
//

import SwiftUI

struct HighlightButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .overlay {
                configuration.isPressed ? Color.accent.opacity(0.4) : Color.accent.opacity(0)
            }
            .animation(.smooth, value: configuration.isPressed)
    }
    
} // 🧱

struct PressableBtuttonStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.smooth, value: configuration.isPressed)
    }
    
} // 🧱

enum ButtonStyleOption {
    case press, highlight, plain
}

extension View {
    
    @ViewBuilder
    func anyButton(_ option: ButtonStyleOption = .plain, action: @escaping () -> Void) -> some View {
        switch option {
        case .press:
            self.pressableButton(action: action)
        case .highlight:
            self.highlighButton(action: action)
        case .plain:
            self.plainButton(action: action)
        }
    }
    
    private func plainButton(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            self
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func highlighButton(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            self
        }
        .buttonStyle(HighlightButtonStyle())
    }
    
    private func pressableButton(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            self
        }
        .buttonStyle(PressableBtuttonStyle())
    }
    
} /// 🧱

#Preview {
    VStack(alignment: .center) {
        
        Text("Hello world")
            .padding()
            .frame(maxWidth: .infinity)
            .tappableBackground()
            .anyButton(.highlight, action: {
                ///
            })
            .padding()
        
        Text("Hello world")
            .callToActionButton()
            .anyButton(.press, action: {
                ///
            })
            .padding()
        
        Text("Hello world")
            .callToActionButton()
            .anyButton(action: {
                ///
            })
            .padding()
    }
}
