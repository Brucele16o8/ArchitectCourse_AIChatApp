//
//  OnboardingColorView.swift
//  AIChatCourse
//
//  Created by Tung Le on 1/10/2025.
//

import SwiftUI

struct OnboardingColorDelegate {
    var path: Binding<[OnBoardingPathOption]>

}

struct OnboardingColorView: View {
    
    @State var viewModel: OnboardingColorViewModel
    
    let delegate: OnboardingColorDelegate
    
    var body: some View {
        ScrollView {
            colorGrid
                .padding(.horizontal, 24)
        }
        .safeAreaInset(edge: .bottom, alignment: .center, spacing: 16) {
            ZStack {
                if let selectedColor = viewModel.selectedColor {
                    ctaButton(selectedColor: selectedColor)
                        .transition(AnyTransition.move(edge: .bottom))
                }
            }
            .padding(24)
            .background(Color(uiColor: .systemBackground))
        }
        .animation(.bouncy, value: viewModel.selectedColor)
        .toolbar(.hidden, for: .navigationBar)
        .screenAppearAnalytics(name: "OnboardingColorView")
    }
    
    // MARK: - Subview
    private func ctaButton(selectedColor: Color) -> some View {
        Text("Continue")
            .callToActionButton()
            .anyButton(.press) {
                viewModel.onContinueButtonPressed(path: delegate.path)
            }
        .accessibilityIdentifier("ContinueButton")
    }
    
    private var colorGrid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3),
            alignment: .center,
            spacing: 16,
            pinnedViews: [.sectionHeaders],
            content: {
                Section {
                    ForEach(viewModel.profileColors, id: \.self) { color in
                        Circle()
                            .fill(.accent)
                            .overlay(
                                color
                                    .clipShape(Circle())
                                    .padding(viewModel.selectedColor == color ? 10 : 0)
                            )
                            .onTapGesture {
                                viewModel.onColorPressed(color: color)
                            }
                            .accessibilityIdentifier("ColorCircle")
                    }
                } header: {
                    Text("Select a profile color")
                        .multilineTextAlignment(.center)
                        .font(.headline)
                }
            }
        )
    }
    
} // 🧱

#Preview {
    let container = DevPreview.shared.container
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    
    return NavigationStack {
        builder
            .onboardingColorView(
                delegate: OnboardingColorDelegate(path: .constant([]))
            )
    }
    .previewEnvironment()
}
