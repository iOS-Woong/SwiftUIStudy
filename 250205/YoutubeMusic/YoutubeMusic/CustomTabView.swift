//
//  CustomTabView.swift
//  YoutubeMusic
//
//  Created by KOVI on 1/31/25.
//

import SwiftUI

enum Tab {
    case home
    case sample
    case browse
    case storage
}

struct CustomTabView: View {
    
    @Binding var selectedTab: Tab
    @Binding var currentScreenCoverPercentage: CGFloat
    
    var body: some View {
        TabView {
            Spacer()
            
            button(iconName: "house", title: "홈", tab: .home)
            
            Spacer()
            
            button(iconName: "play.rectangle.on.rectangle", title: "샘플", tab: .sample)
            
            Spacer()
            
            button(iconName: "safari", title: "둘러보기", tab: .browse)
            
            Spacer()
            
            button(iconName: "music.note.house", title: "보관함", tab: .storage)
            
            Spacer()
        }
        .background(.tabbar)
        .offset(y: tabbarOffset)
    }
    
    private var tabbarOffset: CGFloat {
        let hideDistance: CGFloat = 100
        
        return (currentScreenCoverPercentage / 100) * hideDistance
    }
    
    private func button(iconName: String, title: String, tab: Tab) -> some View {
        Button {
            self.selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(selectedTab == tab ? .white : .gray)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(selectedTab == tab ? .white : .gray)
            }
        }
    }
}

#Preview {
    CustomTabView(selectedTab: .constant(.home), currentScreenCoverPercentage: .constant(100))
}
