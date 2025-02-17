//
//  CustomUITabbar.swift
//  YoutubeMusic
//
//  Created by KOVI on 2/17/25.
//

import SwiftUI

struct TabBarControllerWrapper: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> UITabBarController {
        let tabBarController = UITabBarController()
        
        let homeVC = UIHostingController(rootView: ToggleView())
        homeVC.tabBarItem = UITabBarItem(
            title: "Home", image: UIImage(systemName: "house"), tag: 0
        )
        
        let sampleVC = UIHostingController(rootView: Text("안녕")
                                                .foregroundColor(.white)
                                                .background(Color.black))
        sampleVC.tabBarItem = UITabBarItem(
            title: "Sample", image: UIImage(systemName: "play.rectangle.on.rectangle"), tag: 1
        )
        
        let browseVC = UIHostingController(rootView: Color.green)
        browseVC.tabBarItem = UITabBarItem(
            title: "Browse", image: UIImage(systemName: "safari"), tag: 2
        )
        
        let storageVC = UIHostingController(rootView: Color.green)
        storageVC.tabBarItem = UITabBarItem(
            title: "Storage", image: UIImage(systemName: "music.note.house"), tag: 3
        )
        
        tabBarController.viewControllers = [homeVC, sampleVC, browseVC, storageVC]
        
        return tabBarController
    }
    
    func updateUIViewController(_ uiViewController: UITabBarController, context: Context) {}
}
