# 0122 스터디

**과제:  카톡 앱 오픈채팅방 참여시트**

#### 만든거

https://github.com/user-attachments/assets/d45d9d89-a1c1-493c-9d21-0514114838ce

#### 과제로 받은거

https://github.com/user-attachments/assets/e0ef6b3b-d6a8-4f77-94f2-cbcc3de1b675

#### 실제 카톡 오픈챗 참가화면


https://github.com/user-attachments/assets/3242d3f8-ab9d-4a84-91d9-0e58f0d200db

-----

### 1. 사고흐름

- 바텀 시트와 매우 유사하다고 생각했다.
- 아니 사실은 만들어야하는 영상을 보고 이건 바텀시트로 구현했구나! 라고 생각했다.
- 시트의 .Background(SomeLayer())의 SomeLayer를 UIRepresentable으로 골라내어 커스텀하고 그것을 그림이 들어간 백그라운드를 대체하면 되겠다.
- 그러면 별도의 DragGesture를 달아서 offset을 조정하는 등의 UI 액션을 복잡하게 처리 해주지 않아도 될 것
- 그러면 별도의 DragGesture 내에서 일정 임계값을 넘기면 시트가 펴지거나 줄어드는 과정을 처리하지 않아도 될 것
- 그러면 별도의 .presentationDetent 속성을 통해서 시트의 한계 값을 변수로 컨트롤 해주지 않아도 될 것
- 애플에서 레이아웃에 관련되어 이미 1차적으로 처리 해 두었기에 별도의 추가적인 레이아웃 처리가 필요하지않다. (keyboard, safearea등)
- 위의 과정들을 정리하여 구현된다면 더 코드가 간결해지고, 간결하기에 유지보수성 역시 좋은 코드가 될 것이라고 생각했다.
- 하지만, 나의 이번 구현은 오답에 더 가까웠다.

### 2. 구현에 대해서

```swift
.sheet(isPresented: $showSheet) {
    ZStack {
        GeometryReader { geometry in
            ChatDescView()
                .onChange(of: geometry.size) { newValue in
                    currentSheetHeight = geometry.size.height
                }
        }
    }
    .presentationDetents([.medium, .height(650)])
    .interactiveDismissDisabled(true)
    .background(NightCityBackgroundView(currentSheetHeight: $currentSheetHeight))
}
```

- 우선, 앞서 서술한대로 .sheet를 사용헀다.
- 시트의 현재 올라간 height를 측정하기위해서 내부의 컨텐츠에 ZStack 한번 더 입혀주었고, 
그 ZStack을 측정하기 위해 GeometryReader를 활용하였다. (시트의 높이에 따라 배경을 위아래로 offset 주기위해)

```swift
* .sheet의 계층 구조 트리

UITransitionView // 화면 전환 애니메이션을 관리하는 내부 컨테이너 (가장 SUPER 🔼 )
├── UIDimmingView // 시트가 표시될 때, 배경을 어둡게 디밍하는 뷰
├── UIDropShadowView // 시트에 그림자 효과를 줘서 시트가 떠있게 보이게 하는 뷰
│   ├── _UIRoundedRectShadowView // 시트 모서리 라운드 처리 뷰
│   ├── UIView // 시트의 콘텐츠를 담는 주요 컨테이너
│   │   ├── UIView // 중첩
│   │   │   ├── _UIHostingView<AnyView> // SwiftUI의 .Background를 UIView로 대체하기위한 호스팅 아래동일
│   │   │   │   ├── PlatformViewHost<PlatformViewRepresentableAdaptor<NightCityBackgroundView>>
│   │   │   │   │   └── UIView 
│   │   │   ├── _UIGraphicsView // SwiftUI 그래픽처리
│   │   │   ├── _UIGraphicsView ..
│   │   │   ├── CGDrawingView ..
│   │   │   ├── CGDrawingView ..
│   │   │   ├── _UIGraphicsView ..
│   │   │   └── CGDrawingView ..
│   │   ├── _UIGrabber // 시트 상하단 드래그 하기위한 또 다른 핸들러
│   │   │   ├── _UILumaTrackingBackdropView ..
│   │   │   └── UIVisualEffectView ..
│   │   │       └── _UIVisualEffectBackdropView ..
│   │   └── _UIGrabber .. 
│   │       ├── _UILumaTrackingBackdropView ..
│   │       └── UIVisualEffectView ..
│   │           └── _UIVisualEffectBackdropView ..
├── UITransitionView
```

- 내가 건드려야 할 부위는 UIWindow의 가장 앞단이므로 UITransitionView가 되겠다.

```swift
fileprivate extension UIView {
    var viewBeforeWindow: UIView? {
        if let superview, superview is UIWindow {
            return self
        }
        
        return superview?.viewBeforeWindow
    }
}
```

- 재귀하여 가장 앞단의 뷰를 찾아내서 그곳에 컨텐츠를 삽입한다. (아래와 같이)

```swift
fileprivate struct NightCityBackgroundView: UIViewRepresentable {
    
    @Binding var currentSheetHeight: CGFloat
    
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        
        DispatchQueue.main.async {
            if let uiSheetView = containerView.viewBeforeWindow {
                let backgroundView = UIHostingController(
                    rootView: SwiftUINightCitySheetContainerView(
                        currentSheetHeight: $currentSheetHeight
                    )
                )
                let hostedView = backgroundView.view!
                
                hostedView.frame = uiSheetView.bounds
                uiSheetView.insertSubview(hostedView, at: .zero)
                
                let symbolConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold, scale: .default)
                
                let closeButton = UIButton()
                let closeImage = UIImage(systemName: "xmark", withConfiguration: symbolConfig)
                closeButton.tintColor = .white
                closeButton.setImage(closeImage, for: .normal)
                
                let shareButton = UIButton()
                let shareImage = UIImage(systemName: "square.and.arrow.up", withConfiguration: symbolConfig)
                shareButton.tintColor = .white
                shareButton.setImage(shareImage, for: .normal)
                
                uiSheetView.addSubview(shareButton)
                uiSheetView.addSubview(closeButton)
                
                closeButton.snp.makeConstraints {
                    $0.width.height.equalTo(24)
                    $0.top.equalTo(uiSheetView).offset(60)
                    $0.leading.equalTo(uiSheetView).offset(20)
                }
                
                shareButton.snp.makeConstraints {
                    $0.width.height.equalTo(24)
                    $0.top.equalTo(uiSheetView).offset(60)
                    $0.trailing.equalTo(uiSheetView).offset(-20)
                }
            }
        }
        
        return containerView
    }
}
```

- UITransitionView에서 시트 외부영역에 사용할 컨텐츠(배경뷰 + 인터랙션 가능한 버튼)들을 추가하여 해결하였다.

  
- 주의할점:
    - 시트 외부에서 사용할 컨텐츠 중 인터랙션이 필요한 컴포넌트가 있다면 UITransition에 직접 추가하여야한다.
    - 어떤 AllButtonView를 생성하여 해당 View를 UITransitionView에 담으면 인터랙션이 안되더라.
    - 근데 UITransitionView에 직접 addSubview를 하면 정상적으로 탭이 가능해진다.
    - 정확하게 이유는 잘 모르겠다. 가장 제스쳐의 우선순위가 다른가
    - 근데 이런 꼼수도 곧 신경쓸 필요가 없어진다.
    - iOS 16.4 부터는 원하는 Background에 인터랙션 가능한 컨텐츠를 담은 뷰를 담아두고서
    - .presentationBackgroundInteraction(.enabled) 속성을 적용하면 뒷단에도 모두 인터랙션이 가능해진다.

### 3. 스터디에서 나온 이야기

- “요구사항을 지키려면 시트로는 구현이 안되는 것 같다.”
    - 정말 요구사항은 시트가 아니였다. 영상으로 볼때는 시트로 처리할 수 있겠다 싶었는데
    - 다른점1. 저 구현에는 일단 애니메이션이 달려있지않다.
    - 다른점2. 한계점(.medium)에서 바텀으로 드래그 시 감속 & 고무줄되는 효과가 없다.
    - 다른점3. 하단 버튼은 view의 bottom에 고정되어 한계점에서 하단으로 드래그 시, 이동되거나 왔다갔다하지않는다.
    (하지만, 내 구현은 그렇다.)
    
- “기획의 변경에 잦은 변경에 대처하려면 커스텀 구현이 정답에 조금 더 가까운 것 같다.”
    - 지난 번에 사내에서 기능 구현을 할 때도 같은 경험을 한 것 같다. 회사 프로젝트의 최소버전타겟은 iOS버전은 15.0 이라 UIKit Modal로 sheet.detents 를 [.medium(), .large()] 등의 속성밖에 적용되지 않았는데 기획측에선 컨텐츠가 한눈에 보여야한다고 정확한 사이즈를 올려주길 바랬다.
    - 이 때, 나의 구현에선 시트로 화면전환하다가 기존코드는 못쓰고, 새로운 뷰를 아예 만들어버리는 공수가 발생하였음.
    - 이런 경우에 대처하기 위해선 커스텀 구현이 조금 더 나아보인다.

- 매몰되지 말아야겠다.
    - 하나의 아이디어로 구현을 하다보면 세부사항에 치중하느라 다른 부분은 잘 보지 못하는 경향이 있다.
    - 기능(문제)에서 요구하는 사항을 더 잘 이해하자

---

### 부수적인것

`.fixedSize(horizontal: false, vertical: true)` 를 하면 의도치않은 텍스트 애니메이션이 방지된다.

`접근성 opt + command + ( + - )` 시뮬레이터에서 해당 단축키를 눌러서 테스트 해볼 수 있다.
