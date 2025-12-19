//
//  AsyncCallToActionButton.swift
//  AIChatCourse
//
//  Created by Tung Le on 14/10/2025.
//

import SwiftUI

struct AsyncCallToActionButton: View {
    
    var isLoading: Bool = false
    var title: String = "Save"
    var action: () -> Void
    
    var body: some View {
        ZStack {
            if isLoading {
                ProgressView()
                    .tint(Color.white)
            } else {
                Text(title)
            }
        }
        .callToActionButton()
        .anyButton(.press) {
            action()
        }
        .disabled(isLoading)
    }
}

private struct Preview: View {
    
    @State private var isLoading: Bool = false
    
    var body: some View {
        AsyncCallToActionButton(
            isLoading: isLoading,
            title: "Finish",
            action: {
                
            }
        )
    }
}

#Preview {
    Preview()
        .padding()
}
