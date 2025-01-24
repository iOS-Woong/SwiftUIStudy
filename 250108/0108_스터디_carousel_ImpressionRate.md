# 0108 스터디

**과제: SwiftUI에서 Carousel 구현하기 & Page Impression 측정하기**

**SwiftUI로 구현한 Carousel**

<video width="600" controls>
  <source src="/Users/kovihouseteam/Downloads/e99a2bee-9e7d-4d69-9f11-b99d12cded88_Export-a1992869-a64a-4959-afc8-61a5a732964c/0108 스터디 17684720cf9480199350d688e0a5688c/Simulator_Screen_Recording_-_iPhone_16_Pro_Max_-_2025-01-09_at_15.01.39.mov">
</video>

---

### 1. 스크롤의 구현

- 나는 최초 구현에서 ForEach 내부에서 중첩되는 ZStack으로 아이템을 여러개 배치하였다.
- 그들의 간격은 `인덱스 * (itemWidth + padding)`  로 각 아이템간에 offset을 주도록 구현하였으며
- 이로써, 별도의 ScrollView를 선언하지 않는 방식으로 스크롤이 가능한 커스텀뷰를 만들었다.

```swift
// PagingScrollView.swift

var body: some View {
    ZStack(alignment: .center) {
        let globalOffset = currentScrollOffSet(activePageIndex: activePageIndex, dragOffset: dragOffset)
        
        ForEach(0..<self.extendedItemCount, id: \.self) { index in
            LazyVStack {
                Text("\(index) Index")
                    .offset(x: baseTileOffset(index: index) + globalOffset)
                items[index]
                    .frame(width: tileWidth)
                    .offset(x: baseTileOffset(index: index) + globalOffset)
            }
        }
    }
```

### 2. 스크롤 페이징 기능의 구현

- **DragGesture로 사용자 스크롤을 감지**
    - onChagned & onEnded로 드래그 할 경우,  드래그를 할 때마다 dragOffset에 드래그 이동량을 dragOffset에 할당해주었음.
- **Drag가 끝나면 onEnded에서 새 페이지 인덱스를 계산하여 애니메이션 처리**
    - `computeIndexAfterDrag()` 메서드를 통해 dragOffset과 현재 페이지 인덱스를 합산하여 새로운 페이지 인덱스를 구했음.
    - 구한 값을 withAnimation 블럭 내부의 activePageIndex에 할당하여 해당 페이지로 페이징 기능으로 나타내지도록 구현함.

```swift
.simultaneousGesture(
    DragGesture(minimumDistance: 1, coordinateSpace: .local)
        .onChanged { value in
            dragOffset = value.translation.width
            
            let targetOffset = currentScrollOffSet(activePageIndex: activePageIndex, dragOffset: dragOffset)
            currentFloatIndex = floatIndex(targetOffset)
        }
        .onEnded { value in
            let newIndex = computeIndexAfterDrag()
            
            withAnimation(animation) {
                dragOffset = 0
                activePageIndex = newIndex
            }
            
            if activePageIndex < originItemCount {
                activePageIndex += originItemCount
            } else if activePageIndex >= originItemCount * 2 {
                activePageIndex -= originItemCount
            }
            
            let finalOffset = currentScrollOffSet(activePageIndex: activePageIndex, dragOffset: 0)
            currentFloatIndex = floatIndex(finalOffset)
        }
)
```

### 3. Index Active Rate (Impression) 을 측정하는 원리

- offset을 (itemSize + itemPadding)으로 나누어 현재 스크롤의 floatIndex로 만든다.
- 해당 값을 %로 나타낸다. 
(ex. 만약, floatIndex == 1.64 라면, 1인덱스의 활성도는 64%이며, 2인덱스는 36% 라는 구조로 접근)

---

## 스터디에서 나온 이야기

현업에서 주로 사용 하시는 기술스택에 따라 스유로 작성해온 분들과 유킷으로 UIRepresentable하여 작성해온 분들이 있었다. 많은 말들이 오갔다. 그 중에 몇가지 말들을 되짚어보자면

“SwiftUI가 제공하지 않는 소스들이 있다면 억지로 SwiftUI 뷰를 완전하게 커스텀하기보다 조금이라도 더 안정성이 보장된 UIKit을 활용하는게 더 좋은 방법이 아닐까요?” 라는 말이 있었다. 

즉, UICollectionViewCompositionalLayout의 페이징 기능, Collection 내부의 스크롤뷰에 적용되는 감속 스프링, 고무줄 효과 등을 뷰 내부의 기능에서 배제하면서 까지 억지로 완전한 커스텀뷰를 만들 필요는 없다고 생각한다는게 요점이였다.

[https://medium.com/@esskeetit/how-uiscrollview-works-e418adc47060](https://medium.com/@esskeetit/how-uiscrollview-works-e418adc47060)

위 글에서는 애플에서 ScrollView를 만들기위해 얼마나 많은 고민을 통해 만들어진 컴포넌트인지를 잘 보여주고있다.

다른 말로는

“SwiftUI로 만들어도 사용성은 충분히 나온다. 스유의 가장 큰 선언형의 장점을 살릴 수 있다면 이용하는 것도 좋은 방법이다.”

즉, SwiftUI의 코드가 익숙한 사람이라면 정말 세부적인 요구사항이 아닌 이상 SwiftUI로 코드를 작성하는 것도 생산성을 높일 수 있으니 나쁘지 않은 방법이라고 생각한다는 것이 요점. 
실제로 코드를 보면 UIKit 코드보다 훨씬 더 직관적으로 이해가 가능하며, 특히 애니메이션 구현부분에서 상당히 적은 코드로 많은 동작을 세팅이 가능해보여 생산성 & 가독성 측면에서 큰 이점을 가져가는 것 같았다.

### 재구성해보며

원래 만들었던 SwiftUI의 Carousel 코드를 UIKit컴포지셔널컬렉션으로 UIRepresentable 및 래핑하여 동작시켜보았다.
그동안엔, 스크롤뷰의 세부적인 동작에 대해선 생각 해보지않았는데 UIKit에서 기본에 제공하던 기능이 생각보다 많았다.
특히, 스크롤 가속에 따라서 2개가 한꺼번에 페이징 되는 것, 아이템의 끝 경계에선 아주 느리게 감속하여 스크롤되는 등

Infinity Carousel 자체를 구현하는 것은 개발적으로 큰 난이도를 요하는 것이 아니기에 생각 해볼 것이 없었지만,
SwiftUI와 UIKit을 통해서 각각의 UI로 구성 한다는 점에서 오는 차이에서 이 두가지를 깊게 탐구 해볼 수 있는 시간이 된 것 같다.

좋은시간

**UIViewRepresentable로 재구성 해 본 Carousel**

[Simulator Screen Recording - iPhone 16 Pro - 2025-01-09 at 15.02.08.mov](0108%20%E1%84%89%E1%85%B3%E1%84%90%E1%85%A5%E1%84%83%E1%85%B5%2017684720cf9480199350d688e0a5688c/Simulator_Screen_Recording_-_iPhone_16_Pro_-_2025-01-09_at_15.02.08.mov)

<video width="600" controls>
  <source src="/Users/kovihouseteam/Downloads/e99a2bee-9e7d-4d69-9f11-b99d12cded88_Export-a1992869-a64a-4959-afc8-61a5a732964c/0108 스터디 17684720cf9480199350d688e0a5688c/Simulator_Screen_Recording_-_iPhone_16_Pro_Max_-_2025-01-09_at_15.01.39.mov" type="video/quicktime">
</video>

