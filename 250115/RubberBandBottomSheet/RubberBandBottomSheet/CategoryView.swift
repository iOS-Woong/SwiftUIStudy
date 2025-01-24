//
//  CategoryView.swift
//  RubberBandBottomSheet
//
//  Created by KOVI on 1/13/25.
//

import SwiftUI

struct CategoryView: View {
    var rows: [GridItem] = Array(repeating: .init(), count: 2)
    var data: [String] = [
        "🍎 식품", "⚒️ 생활",
        "💻 전자제품", "🧴 뷰티",
        "👕 의류", "✈️ 여행취미",
        "🎾 스포츠", "🍼 출산육아",
        "🏠 인테리어", "📗 도서",
        "👟 패션잡화"
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("카테고리")
                .font(.title2.bold())
                .foregroundColor(.white)
                .padding([.leading, .top], 15)
            LazyVGrid(columns: rows) {
                ForEach(data, id: \.self) { categoryName in
                    Button {
                        // TODO: Action
                    } label: {
                        categoryButton(cateName: categoryName)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .background(Color.categoryStack)
        .cornerRadius(25)
        .padding(20)
    }
    
    func categoryButton(cateName: String) -> some View {
        HStack {
            Text(cateName)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            Spacer()
        }
        .padding([.horizontal, .vertical], 15)
        .cornerRadius(8)
    }
}
