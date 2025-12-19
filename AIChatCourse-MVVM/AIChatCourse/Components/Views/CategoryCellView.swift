//
//  CategoryCellView.swift
//  AIChatCourse
//
//  Created by Tung Le on 13/10/2025.
//

import SwiftUI

struct CategoryCellView: View {
    
    var title: String = "Aliens"
    var imageName: String = Constants.randomImage
    var font: Font = .title2
    var cornerRadius: CGFloat = 16
    
    var body: some View {
        ImageLoaderView(urlString: imageName)
            .aspectRatio(1, contentMode: .fit)
            .overlay(alignment: .bottomLeading) {
                Text(title)
                    .font(font)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .addingGradientBackgroundForText()
                    .lineLimit(1)
                    .minimumScaleFactor(0.3)
            }
            .cornerRadius(cornerRadius)
    }
}

#Preview {
    VStack {
        CategoryCellView()
            .frame(width: 150, height: 150)
        
        CategoryCellView()
            .frame(width: 300, height: 300)
    }
}
