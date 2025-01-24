//
//  CarouselModel.swift
//  Carousel
//
//  Created by KOVI on 1/2/25.
//

import Foundation
import AVKit
import SwiftUI

protocol CarouselStateProtocol {
    var navigationTitle: String { get }
    var doggiesList: [Doggy] { get }
    var players: [Int: AVPlayer] { get }
    var currentFloatIndex: CGFloat { get }
}

protocol CarouselActionProtocol: AnyObject {
    func setNavigationTitle(text: String)
    func showDoggiesList(doggies: [Doggy])
    func updateCurrentFloatIndex(index: CGFloat)
}

// MARK: State

final class CarouselModel: ObservableObject, CarouselStateProtocol {
    @Published var doggiesList: [Doggy] = .init()
    @Published var players: [Int : AVPlayer] = .init()
    @Published var navigationTitle: String = "몇마리?"
    @Published var currentFloatIndex: CGFloat = 0
}

// MARK: Reduce

extension CarouselModel: CarouselActionProtocol {
    
    func setNavigationTitle(text: String) {
        navigationTitle = text
    }
    
    func showDoggiesList(doggies: [Doggy]) {
        doggiesList = doggies
        
        for (index, doggy) in doggies.enumerated() {
            guard
                doggy.mediaType == .mp4,
                let url = URL(string: doggy.url) else { continue }
            players[index] = AVPlayer(url: url)
        }
    }
    
    func updateCurrentFloatIndex(index: CGFloat) {
        currentFloatIndex = index
    }
}
