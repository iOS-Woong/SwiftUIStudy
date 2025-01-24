//
//  MVIContainer.swift
//  Carousel
//
//  Created by KOVI on 1/2/25.
//

import Combine
import Foundation

final class MVIContainer<Intent, Model>: ObservableObject {
    
    let intent: Intent
    let model: Model
    
    private var cancellable: Set<AnyCancellable> = []
    
    init(intent: Intent, model: Model, modelChangedPublisher: ObjectWillChangePublisher) {
        self.intent = intent
        self.model = model
        
        modelChangedPublisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: objectWillChange.send)
            .store(in: &cancellable)
    }
}
