//
//  OnboardingCommunityView.swift
//  AIChatCourse
//
//  Created by Tung Le on 23/11/2025.
//
import SwiftUI

struct OnboardingCommunityView: View {
    var body: some View {
        VStack {
            VStack(spacing: 40) {
                ImageLoaderView()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                
                Group {
                    Text("Join our community with over ")
                    +
                    Text("1000+ ")
                        .foregroundStyle(.accent)
                        .fontWeight(.semibold)
                    +
                    Text("custom avatars.\n\nAsk them questions or have a casual conversation!")
                }
                .baselineOffset(6)
                .minimumScaleFactor(0.5)
                .padding(24)
            }
            .frame(maxHeight: .infinity)
            
            /// Button
            NavigationLink {
                OnboardingColorView()
            } label: {
                Text("Continue")
                    .callToActionButton()
            }
            .accessibilityIdentifier("OnboardingCommunityContinueButton")
        }
        .padding(24)
        .font(.title3)
        .toolbar(.hidden, for: .navigationBar)
        .screenAppearAnalytics(name: "OnboardingCommunityView")
    }
}

#Preview {
    NavigationStack {
        OnboardingCommunityView()
    }
    .previewEnvironment()
}
