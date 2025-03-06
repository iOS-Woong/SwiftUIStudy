# 0219 스터디

**과제: Slack 따라잡기 UI**

[과제로 받은거]

https://github.com/user-attachments/assets/775b6834-0237-4b4e-ad22-4b914a14219f

[만든거]


---

## 아이디어

1. 뷰에 드래그제스처를 넣어서 값을 측정해주자.
2. 드래그제스처에서 받아온 값을 기반해서 기울어질 각도 + 이동시킬 거리로 표현해주자.
3. 기울어질 최대 각도를 정의해주고 아무리 드래그가 늘어나더라도 특정각도까지만 드래깅되도록 하자.
4. 화면을 수직축 1/2 을 기점으로하여 시작점이 그 상단에 위치했을 때, 하단에 위치했을 때 기울기를 각각 다르게 해주자.
5. 읽음/읽지않음 처리할 기울기를 0~100(최대) 로 잡고, 그 기울기에 도달했다면 100(최대)로 되어 그 상태로 End 되었다면 플래그를 쏴서 카드를 읽음/읽지않음 처리 & 제거하라고 명령하자.

---

### 1. `.offset`과 `.rotationEffect`로 뷰의 이동 & 회전 표현하기

```swift
Image(uiImage: cardImage)
    ...
    .offset(cardVM.dragOffset)
    .rotationEffect(cardVM.rotationAngle)
    .simultaneousGesture(createDragGesture())
}
```

- offset(**_** offset: CGSize)
- rotationEffect(**_** angle: Angle, anchor: UnitPoint = .center) -> **some** View
- 위 두 메서드로 화면의 이동, 회전을 각각 표현 해줄 수 있음.
- 여기서 Angle(radian:) or Angle(degree:) 이라는 타입을 인자로 전달해주어야하는데 이는 각도라고 생각하면된다.
- ex) 1라디안 = 57.2958도, 3.14 라디안 = 180도, 1디그리 = 1도
- 따라서, dragGesture에서 받아온 value를 통해 드래그 비율을 → to radian → cardVM의 rotationAngle의 각도로 전달 → .rotationEffect를 통해 뷰 업데이트 순으로 이루어지게된다.

### 2. Gesture부 구현

```swift
private func handleDragChanged(value: DragGesture.Value) {
    // 1. 최초 터치 위치한 위치를 저장합니다.
    /// - 시작점이 스크린 상단과 하단일 경우, 각도의 + - 를 각각 나타내주기 위해서)
    if cardVM.startLocation == nil {
        cardVM.startLocation = value.startLocation
    }
    
    // 2. 좌우 드래깅 처리
    /// -          실제드래그거리
    ///      ---------------------        X   0.32( radians )  =  실제 드래그 거리의 비율을 각도로 변환
    ///     최대 드래그 가능 거리
    ///
    let screenWidth = UIScreen.main.bounds.width // 최대로 드래그 가능한 거리
    let currentDragDistance = value.translation.width // 실제 드래그한 거리 (좌측 드래그 시 -, 우측 드래그 시 +)
    let maxRotationAngle = 0.32 // 최대 각도 (18도)
    let calculatedRotation = (currentDragDistance / screenWidth) * maxRotationAngle
    // 3. 1번에서 저장한 StartLocation 기준으로 부호를 조정합니다.
    /// - 시작위치 >  스크린의 중간높이보다 크면, 부호를 뒤집어준다.
    /// - 이는 화면의 중간치를 기준으로 다른방향으로 회전을 주기위해서임.
    /// - 이해가 잘 안 갈 수 있는데 프린트 찍어보다보면 대충 감이옴.
    if let startingPosition = cardVM.startLocation?.y {
        let screenMid = UIScreen.main.bounds.height / 2
        let adjustedRotation = startingPosition < screenMid ? calculatedRotation : -calculatedRotation
        
        cardVM.rotationAngle = Angle(radians: adjustedRotation)
    }
    
    cardVM.dragOffset = value.translation
    
    
    // 4. 스와이프로 읽지않음 읽음 처리
    /// - 실제 드래그 거리  / 최대 드래그 가능 거리 가 비율이 30% 일 때, 100 임
    /// - 만약, 좌측으로 드래그 했을때 (읽지않음) -100 이되어가면서 읽지않음 상태로 가게된다.
    /// - 만약, 우측으로 드래그 했을때 (읽음) +100 이 되어가면서 읽음 상태로 가게된다.
    let calculatePercentage = (currentDragDistance / screenWidth / 0.35) * 100
    let minMaxPercentage = max(-100, min(100, calculatePercentage))
    
    cardVM.readStatePercentage = minMaxPercentage
}
```

- 최초터치 위치 저장 (1설명)
- 드래그 거리를 각도로 변환하는 로직이 2에 담겨있다. (2설명)
- 시작지점이 중간기점에서 하단부분이라면 2에서 계산한 각도를 음수로 준다.(3설명)
- 읽음/읽지않음에 대한 처리를 위해 값을 변환해주는 것 (4설명)

---

### 스터디에서 나온 이야기

“뷰모델을 사용하였는데 뷰모델을 꼭 사용할 이유가 있었는가?”

```swift
final class CardVM: ObservableObject {
    @Published var rotationAngle: Angle = .zero
    @Published var startLocation: CGPoint?
    @Published var dragOffset: CGSize = .zero
    @Published var readStatePercentage: CGFloat = .zero
}
```

- 정확히는 단순히 프로퍼티를 담는 용도로 뷰모델을 사용하였는데 이런경우는 사용할 이유가 없는 것 같다.
- 만약, Gesture부분에서 드래그 값을 회전각으로 변환하는 부 / 드래그 값을 읽기,읽지않음 비율로 변환하는 부 등의 로직이 뷰모델에서 사용되었더라면 납득이 되었을 것.

“뷰모델을 선언하는 부분에서 ObservedObject를 사용한 이유가 있는가?”

- @StateObject @ObservedObject를 활용해서도 같은 구현이 가능하다.
- ??? 둘 사이 차이가 뭐지?

### @ObservedObject

```swift
// SuperView.swift

struct SuperView: View {
        @State private var superCount: Int = 0

        var body: some View {
                NavigationStack {
                        NavigationLink {
                    SubView(superCount: $superCount)
                }
                }
        }
}

// SubView.swift

final class SubViewModel: ObservableObject {
        @Published var count: Int = 0
}

struct SubView: View {
        @ObservedObject let subViewModel = SubViewModel() // ObservedOjt로 선언한 vm
        @Binding var superCount: Int // SuperView와 연결
        
        var body: some View {
            VStack {
                    버튼1 { 누르면 subViewModel의 count를 올린다. +=1 }    
                    버튼2 { 누르면 superCount의 값을 올린다. += 1 }
                }
        }
}
```

1. 위 코드에서 버튼 1을 눌러보자. → 그럼, SubViewModel의 count가 1..2..3 으로 증가하게된다.
2. 위 코드에서 버튼 2를 눌러보자. 
    
    → SuperView의 superCount가 변경된다. SuperView의 superCount가 1..2..3으로 증가하게된다.
    
    → SubView도 새로 이니셜라이즈 된다.
    
    → 어.. 결국, SubViewModel도 재생성되어버렸네?
    
    → count가 0이되어버렸음.
    
3. 이것이 문제다.

### @StateObject

```swift
// @ObservedObject let subViewModel = SubViewModel() // ObservedOjt로 선언한 vm
@StateObject let subViewModel = SubViewModel() // StateObject로 선언한 vm
```

1. 위 코드에서 뷰모델 선언부를 @StateObject 라고 바꿔주자.
2. 위 코드에서 버튼 1을 눌러보자. → 그럼, SubViewModel의 count가 1..2..3 으로 증가하게된다.
3. 위 코드에서 버튼 2를 눌러보자.
    
    → SuperView의 superCount가 변경된다. SuperView의 superCount가 1..2..3으로 증가하게된다.
    
    → SubView도 새로 이니셜라이즈 된다.
    
    → 어 근데? SubViewModel이 재생성이 안됨. (이전의 형태를 그대로 유지하고있음.)
    
    → count가 3임 계속
    
4. 어떻게한거지?
5. 정의를 읽어보자.

---

### @StateObject 공식문서

[https://developer.apple.com/documentation/swiftui/stateobject](https://developer.apple.com/documentation/swiftui/stateobject)

1. @StateObject는 뷰의 라이프사이클 중 한번 뿐 (근데 계속 살아있다는건 아니니까 주의할것)

SwiftUI creates a new instance of the model object only once during the lifetime of the container that declares the STATE object. 
SwiftUI가 모델 객체의 새 인스턴스를 생성하는 경우는 STATEOBJECT를 선언하는 컨테이너의 수명 기간 동안 한 번뿐입니다. 

1. @StateObject로 선언한 뷰모델이 새롭게 태어나는 시점에 대한 설명
For example, SwiftUI doesn’t create a new instance if a view’s inputs change, but does create a new instance if the identity of a view changes. 

예를 들어 SwiftUI에서는 뷰의 입력이 변경되는 경우 새 인스턴스를 생성하지 않지만, 뷰의 ID가 변경되는 경우 새 인스턴스를 생성합니다. 

---

### 그럼 그냥 뷰모델 선언할 때 전부 @StateObject로 다 사용하는게 낫지않음?

- `@StateObject`는 
- **해당 뷰가 ‘직접’ 그 모델 인스턴스를 만들고 소유**할 때 씁니다. (이 뷰가 사라질 때까지 같은 객체를 재사용)
- ObservableObject로 선언한 뷰모델을 싱글소스로 관리하고 싶을 때 쓰는거임

- `@ObservedObject`
- 이미 만들어진 모델 인스턴스를 주입받아서 관찰하고, 변경사항을 UI에 반영하고 싶을 때 씀.

---

### @ObservedObject로 선언된 ViewModel에 @StateObject 값을 주입하는법

```swift
class DataModel: ObservableObject {
    @Published var name = "Some Name"
    @Published var isEnabled = false
}

struct MyView: View {
    @StateObject private var model = DataModel()

    var body: some View {
        Text(model.name)
        MySubView(model: model)
    }
}

struct MySubView: View {
    @ObservedObject var model: DataModel

    var body: some View {
        Toggle("Enabled", isOn: $model.isEnabled)
    }
}
```

[https://developer.apple.com/documentation/swiftui/stateobject](https://developer.apple.com/documentation/swiftui/stateobject)

[https://developer.apple.com/documentation/swiftui/observedobject](https://developer.apple.com/documentation/swiftui/observedobject)

### 결론

- 솔직히 한번에 보고 깊이있게 이해하기는 힘들다.
- 다음 스터디 부터는 뷰모델을 만들어가며, @StateObject와 @ObservedObject를 필요에 따라 적절하게 사용해서 구현해보자.
