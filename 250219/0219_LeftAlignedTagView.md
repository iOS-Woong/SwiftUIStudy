# 0219 스터디

**과제: Left Aligned TagView**

![image](https://github.com/user-attachments/assets/688c8964-1924-45c9-b08e-08928427f63b)

https://github.com/user-attachments/assets/c4b8072d-429e-4713-b5a9-b864437bc3f4

### 1. 구현

- TagRows라는 2차원 배열을 선언한다.
- 태그를 한줄에 표시할 너비 `나는 화면너비` 를 정의 해준다.
- 한개너비 `[left Padding + 텍스트폰트사이즈 + rightPadding]`  를 정의 해준다.
- 태그에 담길 데이터묶음(”안녕”, “나는”, “태그야”)을 순회시킨다.
    - 순회시키며, tagRows에 0번인덱스(첫줄)에 표시가능한너비인지 체크하고,
    - 공간이 있으면 tagRows[0]에 어펜드
    - 공간이 없으면 tagRows[1]을 만들고 그곳에 어펜드!
- ForEach로 Row별로 태그들을 차곡차곡 쌓는다.
- 태그묶음 값의 변경(추가, 변경, 삭제)가 있을 때, 너비를 재계산하여 뷰를 다시그려준다.

### 2. 불참으로 인해 의견이나 코드 참조 할 수 없었음

### 3. UIKit에서의 구현과 SwiftUI에서의 구현차이
- LeftAligendTagView가 그려지기가 많이 간소화된 것 같음
- 1년전 TripChat을 UIKit으로 구성하면서 LeftAlignedTagView를 UIKit에서 구현하였을 땐,
- TagView를 작성해주려면 따로 컬렉션뷰를 지정해주고, 거기에 맞게 레이아웃을 정의해주고 외부에서 폰트사이즈(+padding)에 대한 처리도 별도로 해주었었다.
- 근데 많이 간소화된듯함

```
// LeftAlignedCollectionViewFlowLayout.swift

class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    let customMinimumInteritemSpacingForSectionAt: CGFloat = 8
    var totalHeight: CGFloat = 0 // 셀과 헤더 전체 높이를 계산하기 위한 변수

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let originAttributes = super.layoutAttributesForElements(in: rect) else { return nil }
        
        var leftMargin = sectionInset.left
        var maxY: CGFloat = originAttributes.first?.frame.origin.y ?? 0
        
        let adjustAttributes = originAttributes.compactMap { originalAttribute -> UICollectionViewLayoutAttributes? in
            guard let layoutAttribute = originalAttribute.copy() as? UICollectionViewLayoutAttributes else { return nil }
            
            let isCell = layoutAttribute.representedElementCategory == .cell
            let isHeader = layoutAttribute.representedElementCategory == .supplementaryView
            
            if isCell {
                // 현재 셀의 new row를 그린 상태라면, 좌측 정렬하라.
                if layoutAttribute.frame.origin.y >= maxY {
                    leftMargin = sectionInset.left
                }
                
                layoutAttribute.frame.origin.x = leftMargin
                
                // 셀 너비와 항목 간 간격만큼 왼쪽 여백 증가
                let totalCellWidth = layoutAttribute.frame.width + customMinimumInteritemSpacingForSectionAt
                leftMargin += totalCellWidth
                
                // maxY 값 업데이트, 현재 행의 최대 y 위치를 추적
                maxY = max(layoutAttribute.frame.maxY, maxY)
                totalHeight = maxY
            }
            
            // totalHeight에 값을 더해주는 이유는 CustomTagContentCell의 messageContainer를 사이즈를 다시 그려주기 위해서입니다.
            if isHeader {
                totalHeight += layoutAttribute.frame.height
            }
            
            return layoutAttribute
        }
        
        return adjustAttributes
    }
}

```
