# 0115 스터디

**과제: TOSS 앱의 감속 스크롤 바텀시트 + 바텀에서 떠있는(?)**


---

### 1. ZStack vs BottomSheet

- 위 과제를 받고 떠오르는 생각은 “이걸 ZStack으로 구현하는게 나을까? 아니면 기본적으로 제공하는 바텀시트에서 구현하는게 나을까?”에 대한 생각을 하였다.
- 최초에 고민해보았을 때, 아마도 두가지 방법은 모두 구현에서의 기술적 문제가 없어보였다.
- 최종적으로 난 바텀시트를 선택하였음.
- 이유1. 시트 내부를 동적으로 올리는 presentationDetends(씨지플롯), DragIndicator 등 이미 잘 구성되어있는 UI속성
- 이유2. 시트를 올리고 내리는 애니메이션이 애플이 만든게 내가 구현한거보단 훨씬 더 구리지 않을 것
- 이유3. 이 구현이 아닌 다른구현이라도 키보드 사용등에 대한 대처도 OS 레벨에서 기본적으로 제공 등
- 그럼 내가 ZStack으로 해야 할 이유가 있나?

### 2. 기존 코드와 동일한 방식으로 바텀시트를 올리기에 가독성도 훨씬 더 좋다.

```swift
// extension View.sheet 메서드

extension View {
		nonisolated public func sheet<Content>(
    isPresented: Binding<Bool>,
    onDismiss: (() -> Void)? = nil,
    @ViewBuilder content: @escaping () -> Content)
    -> some View where Content : View
}

// extension View.floatingBottomSheet 메서드

extension View {
    @ViewBuilder
    func floatingBottomSheet<Content: View>(
        isPresented: Binding<Bool>,
        content: @escaping () -> Content) 
        -> some View
    {
        self.sheet(isPresented: isPresented) {
            content()
                .presentationBackground(.clear)
                .presentationDragIndicator(.visible)
        }
    }
}
```

- 내부의 content만 대체되는 방식으로 구현

### 3. DraggableView의 구현

![image.png](0115%20%E1%84%89%E1%85%B3%E1%84%90%E1%85%A5%E1%84%83%E1%85%B5%2018184720cf9480d08babd74b4a94790e/image.png)

[KakaoTalk_Video_2025-01-20-17-44-06.mp4](0115%20%E1%84%89%E1%85%B3%E1%84%90%E1%85%A5%E1%84%83%E1%85%B5%2018184720cf9480d08babd74b4a94790e/KakaoTalk_Video_2025-01-20-17-44-06.mp4)

```swift
// DraggableView 속성

@GestureState private var gestureOffset: CGSize = .zero // @GestureState를 사용하여 드래그 상태를 추적
@State private var finalOffset: CGSize = .zero // @State를 사용하여 최종 위치 관리 (for dismiss)
```

```swift
// gesture 설정

CategoryView()
.offset(
    x: finalOffset.width + gestureOffset.width,
    y: finalOffset.height + gestureOffset.height
)
.gesture(
    DragGesture()
        .updating($gestureOffset) { value, state, _ in
            let translationX = value.translation.width
            let translationY = value.translation.height
            let limitX: CGFloat = 30 /// X축 이동 제한 범위
            let limitY: CGFloat = 100 /// Y축 이동 제한 범위
            let dampingScaleX: CGFloat = 20 /// X의 감속 스케일 (값이 작을수록 감속이 심함.)
            let dampingScaleY: CGFloat = 100 /// Y의 감속 스케일 (값이 클수록 감속은 덜함.)
            
            // 1. X축으로 드래그 된 거리를 감속 함수에 담아서 다시 계산한 값
            let deceleratedX = translationX / (1 + abs(translationX) / dampingScaleX)
            
            onChanged(
                DraggableMessage(
                    horizontalDragRatio: toPercentage(decelerated: deceleratedX, limit: limitX)
                )
            )
            
            // 2. X축의 감속된 값이 Limit를 넘어가는 경우를 찾고 제한한다.
            let limitedX = max(min(deceleratedX, limitX), -limitX)
            
            let finalY: CGFloat
            // 3. Y축이 상단으로 드래그 될 경우에 대해서 처리한다.
            if translationY <= 0 {
                // 4. Y축으로 드래그 된 거리를 감속 함수에 담아서 다시 계산한 값
                let deceleratedY = translationY / (1 + abs(translationY) / dampingScaleY)
                // 5. Y축의 감속된 값이 Limit를 넘어가는 경우를 찾고 제한한다.
                let limitedY = max(deceleratedY, -limitY)
                
                finalY = limitedY
                
                onChanged(
                    DraggableMessage(
                        upwardDragRatio: toPercentage(decelerated: deceleratedY, limit: limitY))
                )

            } else {
                // 6. 위쪽 드래깅이 아닌 아래쪽 드래깅일 경우, 감속함수 등 별다른 처리없이 이동값을 최종값으로 할당한다.
                finalY = translationY
            }
            
            // 7. 제스처가 업데이트 된다.
            state = CGSize(width: limitedX, height: finalY)
            
        }
        .onEnded { value in
            let translationX = value.translation.width
            let translationY = value.translation.height
            let categoryBottomPadding: CGFloat = 20 /// 카테고리뷰의 바텀 패딩
            
            // 1. Y축 드래그 값이 바텀 패딩 이상이면 -> 최종오프셋을 전달시키고 난 후, dismiss 시킨다. (아니면, offset이 [0,0]으로 회귀 후 종료됨)
            if translationY > categoryBottomPadding {
                finalOffset = CGSize(width: translationX, height: translationY)
                
                onDismiss()
            } else {
                onChanged(
                    DraggableMessage(
                        upwardDragRatio: .zero, horizontalDragRatio: .zero)
                )
            }
        }
)
```

### 1. 스크롤의 구현

- updating되는 GestureState의 value를 읽어와서 감속 계산을 한다.
- 그것을 state에 다시 할당한다.
- 그렇게되면 내가 탭 앤 드래그 한 것 보다 실제로 이동한 거리가 더 적게 스크롤 되게 된다.
- 즉, transitionY(Y축으로 이동한 거리)가 커지면 커질수록 더 적게 이동되는 원리
    
    ```swift
    let deceleratedY = translationY / (1 + abs(translationY) / dampingScaleY)
    ```
    

---

### 스터디에서 나온 이야기

**“타겟 버전은 준수하세요”**

- 현재 스터디의 타겟버전은 16.0이다.
- 나는 처음에 적어둔 것 처럼 기술적인 구현에서 문제가 없을 것이라고 생각하고 바로 구현에 들어갔다.
- 하지만, `.presentationBackground(.clear) - 바텀시트 하얀 배경을 clear로 설정하는 속성` 은 16.4에서부터 지원된다..
- 도중에 ZStack으로 모두 다시 만들어야하는게 귀찮아서 그냥 타겟을 올려서 진행했음…
- 실제로 업무를 볼 때, 구현 중 저 기능 하나로 인해 타겟버전을 올리겠는가? 그것도 마이너한 버전으로 0.1~0.2~..4 이렇게? 말도안됨
- 별 뜻 없이 타겟버전을 설정한게 아니라고 말하셨음
- 타겟버전에 따른 기술 가능 여부를 파악하는데 더 많은 시간을 들이고 가능여부를 판단해 볼 필요가 있다.
