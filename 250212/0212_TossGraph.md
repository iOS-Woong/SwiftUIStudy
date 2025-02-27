# 0212 스터디

**과제: 토스 월별 소비내역 상세**



https://github.com/user-attachments/assets/eaa851a2-9293-45e2-b216-e3ba7e0039a3



https://github.com/user-attachments/assets/c1553934-4d76-4e97-8518-337a6af388dd




## 구현 아이디어

1. 총지출액의 경우, `.contentTransition(.numericText())` 메서드를 활용하면 예시와 똑같이 구현 가능하다.
2. 그래프부는 ZStack으로 막대 배경 (Rectangle)을 먼저 깔고, 그 위에 HStack으로 막대기들을 쌓아주었음.
비율을 나타내는 막대기들은 ForEach로 돌면서 `frame(width:)` 를 비율에 맞춰지도록 하였음.
3. 애니메이션의 경우, 앞의 막대(2.의 Rectangle)은 빠르게 날아오고 뒤의 막대 (2.의 Rectangle)는 약간 느리게 날아오는 부분이 있음.
4. 이는 visibleIndices라는 애니메이션을 조절하기 위한 배열 객체를 만들어주고 시간을 지연시키며 값을 넣어주는 것으로 구현했다.

### 애니메이션 구현부

```swift
// ContentView.swift..

// 1. 애니메이션 할 Bar의 ID를 담아두기 위한 객체
@State private var visibleBarIDs: Set<UUID> = [] 

private var barchart: some View {
    ZStack(alignment: .trailing) {
		    // 2. 차트의 회색배경부
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.gray.opacity(0.3))
        
        // 3. 수치를 나타내는 바(막대기부)
        HStack(spacing: 2) {
            ForEach(stackedBarData) { category in
                let barWidth = (category.amount / totalAmount) * maxWidth
                
                Rectangle()
                    .fill(category.type.color)
                    .frame(width: barWidth, height: 30)
                    // 4. visibleBarIDs를 탐색하여 존재하지않으면 maxWidth 
                    // 즉, 차트 외부까지 안보이게 넘겨 버린다.(+ clipShape 처리해서 안보임)
                    .offset(x: visibleBarIDs.contains(category.id) ? 0 : maxWidth)
                    // 5. smooth하도록 기본설정하고 별도 delay는 이곳에서 설정해주지않았다.
                    .animation(.smooth, value: visibleBarIDs)
            }
        }
        .padding(.horizontal, 4)
    }
    .frame(width: maxWidth, height: 30)
    .clipShape(RoundedRectangle(cornerRadius: 20))
}

// 6. 1에 준비된 빈 객체에 값을 딜레이를 주면서 채워 넣는다.
// + 이 함수는 차트를 리셋(새로운 월별차트로 이동) 하거나, onAppear 할 때 불리도록 함.
private func animateBarsSequentially() {
    visibleBarIDs.removeAll()
    
    for (index, bar) in stackedBarData.enumerated() {
		    // 인덱스별로 
		    // 1 = 0.2  
		    // 2 = 0.4, 
		    // 3 = 0.6 순으로 딜레이된다.
        let delayPerIndex = Double(index) * 0.2
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delayPerIndex) {
            withAnimation {
                let _ = visibleBarIDs.insert(bar.id)
            }
        }
    }
}
```

## 스터디에서의 대화 .transition(.asymmetric())

- 어떤 분은 .animation() 으로 처리하지 않고, .transition(.asymmetric()) 으로 처리했더라.

```swift
1. 뷰의 전환을 연결합니다.

nonisolated
func transition(_ t: AnyTransition) -> some View

1. AnyTransition에 속해있음
2. Provides a composite transition that uses a different transition for insertion versus removal.
3. 번역: 삽입과 제거에 다른 전환을 사용하는 복합 전환을 제공합니다.
static func asymmetric(
    insertion: AnyTransition,
    removal: AnyTransition
) -> AnyTransition

이런 메서드가 존재함.
```

- 저 메서드를 활용하면 뷰가 insertion 될 때, 특정 효과를 지정해주고, 뷰가 removal 될 때 특정 효과를 지정해주는게 가능해짐
- 실제로도 Toss 원본 화면을 보면 insertion은 .move()를 통해서 우측에서 좌측으로 이동하고, removal은 .opacity를 통해서 제어하는 것 같다.

[https://www.reddit.com/r/SwiftUI/comments/17w5vfi/animation_vs_transition_basics/](https://www.reddit.com/r/SwiftUI/comments/17w5vfi/animation_vs_transition_basics/)
