//
//  CarouselIntent.swift
//  Carousel
//
//  Created by KOVI on 1/2/25.
//

import Foundation

protocol CarouselIntentProtocol {
    func viewOnAppear()
    func updateCurrentFloatIndex(index: CGFloat)
}

// MARK: Intent (Mutate)

class CarouselIntent {
    private weak var model: CarouselActionProtocol?
    
    init(model: CarouselActionProtocol) {
        self.model = model
    }
}

extension CarouselIntent: CarouselIntentProtocol {
    func viewOnAppear() {
        Task {
            let results = try await fetchTenDoggies()
            model?.showDoggiesList(doggies: results)
            model?.setNavigationTitle(text: "\(results.count)마리")
        }
    }
    
    func updateCurrentFloatIndex(index: CGFloat) {
        model?.updateCurrentFloatIndex(index: index)
    }
}

extension CarouselIntent {
    private func fetchTenDoggies() async throws -> [Doggy] {
        var doggies: [Doggy] = .init()
        
        for _ in 0..<10 {
            let doggy = try await fetchContent()
            doggies.append(doggy)
        }
        
        return doggies
    }
    
    private func fetchContent() async throws -> Doggy {
        guard let url = URL(string: "https://random.dog/woof.json") else { return Doggy(url: "", mediaType: .image) }
        let (data, _) = try await URLSession.shared.data(from: url)
        let doggyDto = try JSONDecoder().decode(DoggyDTO.self, from: data)
        return doggyDto.toDoggy()
    }
}


