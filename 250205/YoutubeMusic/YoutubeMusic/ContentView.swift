

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .home
    @State private var currentScreenCoverPercentage: CGFloat = .zero
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                mainContent(proxy)
                musicPlayer(proxy)
                TabBarControllerWrapper()
                customTabBar(proxy)
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func mainContent(_ proxy: GeometryProxy) -> some View {
        VStack {
            switch selectedTab {
            case .home:
                ToggleView()
            case .sample:
                Text("안녕")
                    .foregroundColor(.white)
            case .browse:
                youtubeBackgroundImage
            case .storage:
                youtubeBackgroundImage
            }
        }
        .frame(width: proxy.size.width, height: proxy.size.height)
    }
    
    private func musicPlayer(_ proxy: GeometryProxy) -> some View {
        MusicPlayer(
            fullModeHeight: proxy.size.height,
            miniModeHeight: proxy.size.height * 0.0974,
            currentScreenCoverPercentage: $currentScreenCoverPercentage
        )
        .ignoresSafeArea(.all, edges: .top)
    }
    
    private func customTabBar(_ proxy: GeometryProxy) -> some View {
        CustomTabView(
            selectedTab: $selectedTab,
            currentScreenCoverPercentage: $currentScreenCoverPercentage
        )
        .ignoresSafeArea(edges: .bottom)
        .frame(width: proxy.size.width, height: proxy.size.height * 0.0874)
        .background(Color.tabbar)
    }
    
    private var youtubeBackgroundImage: some View {
        Color.green
    }
}
