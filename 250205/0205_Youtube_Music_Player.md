# 0205 스터디

**과제:  유튜브뮤직 앱 펼쳐지는 플레이어**

[KakaoTalk_Video_2025-02-14-14-50-58.mp4](0205%20%E1%84%89%E1%85%B3%E1%84%90%E1%85%A5%E1%84%83%E1%85%B5%2019a84720cf9480b29a66c87a36c2ea10/KakaoTalk_Video_2025-02-14-14-50-58.mp4)

[Simulator Screen Recording - iPhone 16 Pro - 2025-02-14 at 14.55.14.mov](0205%20%E1%84%89%E1%85%B3%E1%84%90%E1%85%A5%E1%84%83%E1%85%B5%2019a84720cf9480b29a66c87a36c2ea10/Simulator_Screen_Recording_-_iPhone_16_Pro_-_2025-02-14_at_14.55.14.mov)

### 1. 아이디어

- **화면 하단에 들어갈 탭바**를 구성한다.
- **ZStack**을 이용해 **탭바 뒤편**(하위 레이어)에 **MusicPlayer 시트**를 배치한다.
- **MusicPlayer 시트**를 **드래그 & 드롭**할 때, 스크롤  임계점(50%)을 넘으면 
**자동으로** 풀스크린(또는 미니 플레이어) 위치로 스냅(snap)되도록 한다.
- **MusicPlayer가 드래그된 offset**을 통해 
전체 화면 중 어느 정도 비율로 MusicPlayer가 펼쳐져 있는지(0~100%) 를 계산하고,
- 탭바도 저 (0~100%) 비율로 하여 화면에서 완전히 내려가는 액션을 구현하자

### ContentView

```swift
struct ContentView: View {
    @State private var selectedTab: Tab = .home
    // Tabbar를 offset 제어하기 위해 MusicPlayer에서 받아온 조정값 (0~100)
    @State private var currentScreenCoverPercentage: CGFloat = .zero
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                mainContent(proxy)
                musicPlayer(proxy)
                customTabBar(proxy)
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func mainContent(_ proxy: GeometryProxy) -> some View {
        VStack {
            switch selectedTab {
            case .home:
                youtubeBackgroundImage
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

```

- ZStack에 Content < MusicPlayer < Tabbar 순으로 포개어지게 쌓았다.
- currentScreenCoverPercentage를 두고, MusicPlayer가 화면이 덮이는 수준을 퍼센티지로 받아왔다.
- 그것을 Tabbar에 가져와서 offset으로 조절해준다.

### MusicPlayer 제스쳐부

```swift
// MusicPlayer.swift

DragGesture()
		.gesture(
		    DragGesture()
		        .onChanged(onDragChanged(_:))
		        .onEnded(onDragEnded(_:))
		)
		

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

```

- 드래그할때마다 `@State dragOffset`을 조절해주어 뷰의 offset이 조정되도록 했다.
- 드래그의 사용중과 끝에서 
ContentView의 조정을위해외부에 공유할 변수인 currentScreenCoverPercentage에 fullModePercentage(0~100)을 할당해준다.

```swift
// CustomTabView.swift

private var tabbarOffset: CGFloat {
    let hideDistance: CGFloat = 100
    
    return (currentScreenCoverPercentage / 100) * hideDistance
}
```

- 받아온 currentScreenCoverPercentage를 
실 offset의 비율로 재계산하여 할당해주는 것으로 아래로 숨기고 보이는 액션을 만들어준다.

---

## 스터디에서 나온 이야기

- 상태 공유가 되는가? (재생/일시정지, 재생 프로그래스)  / 생각보다 과제가 어려워서 이 기능까지는 만들지도 못했다…
- 커스텀 탭바를 사용 할 때, 상태공유를 하는 것에서 약간 어려움이 있다. 어떻게 사용들하는가?
    
    - 정확히는 0번탭에 들어가서 어떤 설정을 마치고, 1번탭에 들어갔다가, 0번탭으로 오게되면 그 것의 상태가 해제된다는 
    
    - 이를 보완하기 위해서 사내에서는 UITabbarController를 래핑해서 주로 사용한다.
    
    - 그런가?
    

### CustomTabView를 만들어서 사용하는 방법

```swift
// customTabview.swift

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
```

[Simulator Screen Recording - iPhone 16 Pro - 2025-02-17 at 10.06.51.mp4](0205%20%E1%84%89%E1%85%B3%E1%84%90%E1%85%A5%E1%84%83%E1%85%B5%2019a84720cf9480b29a66c87a36c2ea10/Simulator_Screen_Recording_-_iPhone_16_Pro_-_2025-02-17_at_10.06.51.mp4)

[화면 기록 2025-02-17 오전 10.13.44.mov](0205%20%E1%84%89%E1%85%B3%E1%84%90%E1%85%A5%E1%84%83%E1%85%B5%2019a84720cf9480b29a66c87a36c2ea10/%E1%84%92%E1%85%AA%E1%84%86%E1%85%A7%E1%86%AB_%E1%84%80%E1%85%B5%E1%84%85%E1%85%A9%E1%86%A8_2025-02-17_%E1%84%8B%E1%85%A9%E1%84%8C%E1%85%A5%E1%86%AB_10.13.44.mov)

- 실제로 탭을 전환할 때마다 뷰의 인스턴스와 함께 생성되고 뷰가 제거될 때 해제되는 것을 확인 할 수 있다.
- 상위 뷰(ContentView)에서 상태를 공유하여 이를 해결 해 줄 수 있겠지만…
- 그렇게되면 4개의 탭의 여러가지 상태들이 ContentView에 공유되어야한다. 
→ 결론적으로 ContentView의 책임이 너무 커지게 되는 결과로 이어지게 될 것

### UITabbarController를 래핑해서 사용하는 방법

[Simulator Screen Recording - iPhone 16 Pro - 2025-02-17 at 10.38.56.mp4](0205%20%E1%84%89%E1%85%B3%E1%84%90%E1%85%A5%E1%84%83%E1%85%B5%2019a84720cf9480b29a66c87a36c2ea10/Simulator_Screen_Recording_-_iPhone_16_Pro_-_2025-02-17_at_10.38.56.mp4)

- 상태공유가 정상적으로 이루어진다.
- UITabbarControlelr에서는 각 탭에 해당하는 뷰 컨트롤러가 한 번 생성된 후 계속 유지되기 때문
- SwiftUI의 기본제공 TabView는 이런걸 처리해두었을까? 
(해봤는데 뭐 어떻게 내부 구성을 했는진 모르겠는데 상태유지에 대해서 처리해놨음)

### SwiftUI의 TabView 순정을 그대로 사용하는 방법

- 하지만, 그대로 사용하는 것은 디자인 커스텀에 제약이 있으므로 좋은 선택지는 아님.
- 따라서, 순정을 쓰되 커스터마이징을 거쳐야 하는 듯하다.

[https://velog.io/@soc06212/SwiftUI-TabView-TabBar-커스터마이징](https://velog.io/@soc06212/SwiftUI-TabView-TabBar-%EC%BB%A4%EC%8A%A4%ED%84%B0%EB%A7%88%EC%9D%B4%EC%A7%95)

- 그냥 UITabbarController 래핑해서 쓸래

### 결론

- 내가 구현한 방식의 CustomTabbar로 SelectedTab을 구현하는 것은 틀린방법에 가깝다.
- 1, 2, 3 탭을 이동해가며 상태 공유 측면에서 의도한대로 작동하지 않기에
- 래핑 할 만한건 래핑해서 쓰자