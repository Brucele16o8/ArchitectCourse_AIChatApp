//
//  ProfileModalView.swift
//  AIChatCourse
//
//  Created by Tung Le on 15/10/2025.
//

import SwiftUI

struct ProfileModalView: View {
    
    var imageName: String? = Constants.randomImage
    var title: String? = "Alpha"
    var subtitle: String? = "Alien"
    var headline: String? = "An alien in the park."
    var onXMarkPressed: () -> Void = { }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topTrailing) {
                if let imageName {
                    ImageLoaderView(urlString: imageName,
                                    forceTransitionAnimation: true)
                        .aspectRatio(contentMode: .fit)
                }
                
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundStyle(Color.black)
                    .padding(4)
                    .tappableBackground()
                    .padding(8)
                    .anyButton(.plain, action: {
                        onXMarkPressed()
                    })
            }
            
            VStack(alignment: .leading, spacing: 4) {
                if let title {
                    Text(title)
                        .font(.title)
                        .fontWeight(.semibold)
                }
                
                if let subtitle {
                    Text(subtitle)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                if let headline {
                    Text(headline)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(.thinMaterial)
        .cornerRadius(16)
    }
    
} // 🧱

#Preview("Modal with image") {
    ZStack {
        Color.gray.ignoresSafeArea()
        
        ProfileModalView()
            .padding(40)
    }
}

#Preview("Modal without image") {
    ZStack {
        Color.gray.ignoresSafeArea()
        
        ProfileModalView(imageName: nil)
            .padding(40)
    }
}
