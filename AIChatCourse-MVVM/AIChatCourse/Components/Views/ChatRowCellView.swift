//
//  ChatRowCellView.swift
//  AIChatCourse
//
//  Created by Tung Le on 13/10/2025.
//

import SwiftUI

struct ChatRowCellView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    var imageName: String? = Constants.randomImage
    var headline: String? = "Alpha"
    var subheadline: String? = "This is the last message in the chat."
    var hasNewChat: Bool = true
    
    var body: some View {
        HStack {
            ZStack {
                if let imageName {
                    ImageLoaderView(urlString: imageName)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            VStack(alignment: .leading) {
                if let headline {
                    Text(headline)
                        .font(.headline)
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                }
                
                if let subheadline {
                    Text(subheadline)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(1)
                }
            }
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if hasNewChat {
                Text("NEW")
                    .badgeButton()
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                    .frame(maxWidth: 50)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(colorScheme.backgroundPrimary)
    }
    
} // 🧱

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        
        List {
            ChatRowCellView()
                .removeListRowFormatting()
            
            ChatRowCellView(hasNewChat: false)
                .removeListRowFormatting()
            
            ChatRowCellView(imageName: nil)
                .removeListRowFormatting()
            
            ChatRowCellView(headline: nil, hasNewChat: false)
                .removeListRowFormatting()
            
            ChatRowCellView(subheadline: nil)
                .removeListRowFormatting()
        }
    }
}
