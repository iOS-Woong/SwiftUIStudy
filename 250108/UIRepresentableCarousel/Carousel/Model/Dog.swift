//
//  Dog.swift
//  Carousel
//
//  Created by KOVI on 1/2/25.
//

import Foundation

enum MediaType: String {
    case mp4 = ".mp4"
    case gif = ".gif"
    case image = "image"
}

struct Doggy: Identifiable, Hashable {
    let id = UUID()
    let url: String
    let mediaType: MediaType
}

struct DoggyDTO: Decodable {
    let fileSizeBytes: Int
    let url: String
    
    func toDoggy() -> Doggy {
        let mediaType: MediaType
        
        if url.hasSuffix(MediaType.mp4.rawValue) {
            mediaType = .mp4
        } else if url.hasSuffix(MediaType.gif.rawValue) {
            mediaType = .gif
        } else {
            mediaType = .image
        }
        
        return Doggy(
            url: url,
            mediaType: mediaType
        )
    }
}
