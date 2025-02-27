//
//  ContentView.swift
//  LeftAlignedTagView
//
//  Created by KOVI on 2/19/25.
//

import SwiftUI

struct ContentView: View {

    //* 서치바
    @State private var searchText: String = ""
    //* 태그
    @State private var tagRows = [[String]]()
    @State private var tags = [String]() // = sampleStrings 샘플데이터
    //* 선택
    @State private var selectedTags = Set<String>()
    //* 삭제
    @State private var tagToRemove: String? = nil
    @State private var showAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(tagRows, id: \.self) { row in
                        HStack(spacing: 8) {
                            ForEach(row, id: \.self) { tag in
                                tagView(tag: tag)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
            }
        }
        .onAppear {
            processRows(availableWidth: UIScreen.main.bounds.width)
        }
        .onChange(of: tags) { _ in
            processRows(availableWidth: UIScreen.main.bounds.width)
        }
        .searchable(text: $searchText, prompt: "search swift") {
            ForEach(searchSuggestions, id: \.self) { suggestion in
                Text(suggestion)
                    .searchCompletion(suggestion)
            }
        }
        .onSubmit(of: .search) {
            tags.append(searchText)
            searchText = String()
        }
        .alert("옵션 선택", isPresented: $showAlert) {
            Button("삭제", role: .destructive) {
                guard let tagToRemove else { return }
                removeTag(tag: tagToRemove)
            }
            
            Button("취소", role: .cancel) { }
            
        } message: {
            Text("정말 삭제할거니?")
        }
    }
    
    // MARK: subviews
    
    private func tagView(tag: String) -> some View {
        ZStack(alignment: .topTrailing) {
            Text(tag)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(selectedTags.contains(tag) ? .indigo : Color.gray.opacity(0.3))
                )
                .fixedSize()
                .onTapGesture {
                    toggleSelection(tag: tag)
                }
            
            Button(action: {
                tagToRemove = tag
                showAlert = true

            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .background(Color.white.clipShape(Circle()))
            }
            .offset(x: 8, y: -8)
        }
        .scaleEffect(selectedTags.contains(tag) ? 0.9 : 1.0)
        .animation(.spring, value: selectedTags.contains(tag))
    }
    
    
    // MARK: logic
    
    private var searchSuggestions: [String] {
        if searchText.isEmpty {
            return []
        } else {
            return tags.filter { $0.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    private func toggleSelection(tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }
    
    private func processRows(availableWidth: CGFloat) {
        tagRows = []
        var currentRow = [String]()
        var currentRowWidth: CGFloat = 0
        
        for tag in tags {
            let tagWidth = tag.calculateWidth(font: .systemFont(ofSize: 16)) + 16
            // 열삽입 가능 O
            if currentRowWidth + tagWidth <= availableWidth {
                currentRow.append(tag)
                currentRowWidth += tagWidth
            } else {
                // 열삽입 불가능 X
                tagRows.append(currentRow)
                currentRow = [tag]
                currentRowWidth = tagWidth
            }
        }
        
        if !currentRow.isEmpty {
            tagRows.append(currentRow)
        }
    }
    
    private func removeTag(tag: String) {
        tags.removeAll { $0 == tag }
    }
}

extension String {
    func calculateWidth(font: UIFont) -> CGFloat {
        let textWidth = (self as NSString).size(withAttributes: [.font: font]).width
        let paddingWidth = 24
        return textWidth + CGFloat(paddingWidth)
    }
}

#Preview {
    ContentView()
}
