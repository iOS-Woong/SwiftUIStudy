//
//  MusicPlayer.swift
//  YoutubeMusic
//
//  Created by KOVI on 1/31/25.
//

import SwiftUI

struct MusicPlayer: View {
    let fullModeHeight: CGFloat // 778
    let miniModeHeight: CGFloat // 75
    
    @Binding private var currentScreenCoverPercentage: CGFloat
    
    @State private var dragOffset: CGFloat = .zero
    @State private var finalOffset: CGFloat = .zero
    
    init(
        fullModeHeight: CGFloat,
        miniModeHeight: CGFloat,
        currentScreenCoverPercentage: Binding<CGFloat>
    ) {
        self.fullModeHeight = fullModeHeight
        self.miniModeHeight = miniModeHeight
        _currentScreenCoverPercentage = currentScreenCoverPercentage
        _finalOffset = State(initialValue: fullModeHeight - miniModeHeight)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                fullmodeAlbumCoverImage
                minimodeContents
            }
            Spacer()
            
            if isExpanded {
                Text("Full Screen Player")
                    .foregroundColor(.white)
                    .font(.title)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: fullModeHeight)
        .background(.tabbar)
        .offset(y: computedOffset)
        .gesture(
            DragGesture()
                .onChanged(onDragChanged(_:))
                .onEnded(onDragEnded(_:))
        )
    }
    
    // MARK: - 서브뷰
    
    private var fullmodeAlbumCoverImage: some View {
        Image("someAlbumCover")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: albumSize, height: albumSize)
            .opacity(fullModePercentage / 100)
    }
    
    private var albumSize: CGFloat {
        let minSize: CGFloat = 60
        let maxSize: CGFloat = 250
        return minSize + (maxSize - minSize) * (fullModePercentage / 100)
    }
    
    private var minimodeContents: some View {
        let miniModePercentage = (100 - fullModePercentage)
        
        return HStack {
            miniModeAlbumCoverImage
            artistAndSongName
            Spacer()
            functionButtons
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
        .overlay(playerLine, alignment: .bottom)
        .opacity(miniModePercentage / 100)
    }
    
    private var miniModeAlbumCoverImage: some View {
        Image("someAlbumCover")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 60, height: 60)
    }
    
    private var artistAndSongName: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("인사")
                .font(.caption.bold())
                .foregroundColor(.white)
            Text("범진(BUMJIN)")
                .font(.caption2)
                .foregroundColor(.white)
        }
    }
    
    private var functionButtons: some View {
        HStack(spacing: 15) {
            Button(action: { print("share") }) {
                Image(systemName: "tv.badge.wifi")
                    .foregroundColor(.white)
            }
            Button(action: { print("play") }) {
                Image(systemName: "play.fill")
                    .foregroundColor(.white)
            }
        }
        .padding(.trailing, 30)
    }
    
    private var playerLine: some View {
        Rectangle()
            .fill(Color.white)
            .frame(height: 1)
    }
    
    // MARK: Action
    
    private func onDragChanged(_ value: DragGesture.Value) {
        dragOffset = value.translation.height
        currentScreenCoverPercentage = fullModePercentage
    }
    
    private func onDragEnded(_ value: DragGesture.Value) {
        let newOffset = finalOffset + value.translation.height
        let midPoint = (fullModeHeight - miniModeHeight) / 2
        
        withAnimation {
            if newOffset < midPoint {
                finalOffset = 0
                currentScreenCoverPercentage = 100.0
            } else {
                finalOffset = fullModeHeight - miniModeHeight
                currentScreenCoverPercentage = 0
            }
            
            dragOffset = 0
        }
    }
    
    // MARK: Logic
    
    private var fullModePercentage: CGFloat {
        let maxOffset = fullModeHeight - miniModeHeight
        return (1 - (computedOffset / maxOffset)) * 100
    }
    
    private var computedOffset: CGFloat {
        let offset = finalOffset + dragOffset
        let draggingOffset = max(offset, 0)
        let clampedDragOffset = min(draggingOffset, fullModeHeight - miniModeHeight) // 드래깅한 오프셋이 최대-최소값을 넘지않도록 설정

        return clampedDragOffset
    }
    
    private var isExpanded: Bool {
        computedOffset < (fullModeHeight - miniModeHeight - 50)
    }
}
