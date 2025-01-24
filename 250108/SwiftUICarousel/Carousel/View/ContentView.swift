//
//  ContentView.swift
//  Carousel
//
//  Created by KOVI on 1/2/25.
//

import SwiftUI
import AVKit
import SDWebImageSwiftUI

fileprivate enum Constant {
    static let tileWidth: CGFloat = UIScreen.main.bounds.width * 0.7
    static let tilePadding: CGFloat = 30
    static let tileRadious: CGFloat = 25
    static let activeRateText: String = "ActiveRate (%)"
}

struct ContentView: View {
    @StateObject var container: MVIContainer<CarouselIntentProtocol, CarouselStateProtocol>
    private var state: CarouselStateProtocol { container.model }
    private var intent: CarouselIntentProtocol { container.intent }
    
    var body: some View {
        NavigationStack {
            VStack {
                PagingScrollView(
                    currentFloatIndex: Binding<CGFloat>(
                        get: { state.currentFloatIndex },
                        set: { changedFloatIndex in intent.updateCurrentFloatIndex(index: changedFloatIndex) }
                    ),
                    tileWidth: Constant.tileWidth,
                    tilePadding: Constant.tilePadding,
                    data: state.doggiesList) { doggy in
                        doggyView(doggy: doggy)
                    }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(Constant.activeRateText)
                    .font(.title2)
                    .bold()
                
                ForEach(0..<state.doggiesList.count, id: \.self) { index in
                    let percentage = activationPercentage(for: index)
                    
                    if percentage > 0 {
                        Text("\(index) \(percentage)%")
                            .font(.body)
                            .bold()
                    } else {
                        Text("\(index) 0") // 빈 텍스트
                            .font(.body)
                    }
                }
            }
            .navigationTitle(state.navigationTitle)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            
            Spacer()
            
        }
        .onAppear {
            intent.viewOnAppear()
        }
    }
    
    @ViewBuilder
    private func doggyView(doggy: Doggy) -> some View {
        if doggy.mediaType != .mp4 {
            webImage(url: doggy.url)
                .frame(width: Constant.tileWidth, height: Constant.tileWidth)
                .cornerRadius(Constant.tileRadious)
                .padding(Constant.tilePadding)
        } else {
            let index = state.doggiesList.firstIndex { $0.id == doggy.id }
            let player = state.players[index!]
            videoPlayer(player: player)
                .frame(width: Constant.tileWidth, height: Constant.tileWidth)
                .cornerRadius(Constant.tileRadious)
                .padding(Constant.tilePadding)
        }
    }
    
    private func webImage(url: String) -> some View {
        WebImage(url: URL(string: url)) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            default:
                Color.black
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
    
    private func videoPlayer(player: AVPlayer?) -> some View {
        player?.currentItem?.preferredPeakBitRate = 300_000
        player?.actionAtItemEnd = .none
        
        return VideoPlayer(player: player)
            .onAppear {
                player?.play()
            }
    }
    
    private func activationPercentage(for index: Int) -> Int {
        let scrollOffset = state.currentFloatIndex
        
        let floorIndex = Int(floor(scrollOffset))
        let ceilIndex = Int(ceil(scrollOffset))
        
        var percentage: CGFloat = 0.0
        
        if index == floorIndex && floorIndex >= 0 {
            let fraction = scrollOffset - CGFloat(floorIndex)
            percentage += (1 - fraction) * 100
        }
        
        if index == ceilIndex && ceilIndex >= 0 && ceilIndex != floorIndex {
            let fraction = scrollOffset - CGFloat(floorIndex)
            percentage += fraction * 100
        }
        
        percentage = round(percentage)
        
        return Int(max(percentage, 0))
    }
}

extension ContentView {
    static func build() -> some View {
        let model = CarouselModel()
        let intent = CarouselIntent(model: model)
        let container = MVIContainer(
            intent: intent as CarouselIntentProtocol,
            model: model as CarouselStateProtocol,
            modelChangedPublisher: model.objectWillChange
        )
        
        let view = ContentView(container: container)
        
        return view
    }
}
