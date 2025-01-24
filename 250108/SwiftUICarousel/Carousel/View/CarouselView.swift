
import SwiftUI

struct PagingScrollView<Data: Identifiable, Content: View>: View {
    
    @Binding private var currentFloatIndex: CGFloat
    
    @State private var activePageIndex: Int
    @State private var dragOffset: CGFloat = 0
    
    private let items: [AnyView]
    
    private let tileWidth: CGFloat
    private let tilePadding: CGFloat
    
    private let originItemCount: Int
    private let extendedItemCount: Int
    
    private let animation = Animation.interactiveSpring()
    
    init?(
        currentFloatIndex: Binding<CGFloat>,
        tileWidth: CGFloat,
        tilePadding: CGFloat,
        data: [Data],
        @ViewBuilder content: @escaping (Data) -> Content)
    {
        guard !data.isEmpty else {
            return nil
        }
        
        self._currentFloatIndex = currentFloatIndex
        self.tileWidth = tileWidth
        self.tilePadding = tilePadding
        
        let duplicatedData = data + data + data
        self.items = duplicatedData.map { AnyView(content($0)) }
        self.originItemCount = data.count
        self.extendedItemCount = duplicatedData.count
        self.activePageIndex = items.count / 3
    }
    
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
    }
    
    private func computeIndexAfterDrag() -> Int {
        let totalOffset = offsetForPageIndex(activePageIndex) + dragOffset
        let logicalScrollOffset = logicalScrollOffset(trueOffset: totalOffset)
        let step = tileWidth + tilePadding
        let floatIndex = logicalScrollOffset / step
        
        var computed = Int(round(floatIndex))
        computed = max(computed, 0)
        computed = min(computed, extendedItemCount - 1)
        
        return computed
    }
    
    private func floatIndex(_ offset: CGFloat) -> CGFloat {
        guard extendedItemCount > 0 else {
            return 0
        }
        let logicalScrollOffset = logicalScrollOffset(trueOffset: offset)
        let floatIndex = (logicalScrollOffset) / (tileWidth + tilePadding)
        let substractLeftExtendedItemFloatIndex = floatIndex - CGFloat(originItemCount)
        
        return substractLeftExtendedItemFloatIndex
    }
    
    private func logicalScrollOffset(trueOffset: CGFloat) -> CGFloat {
        return (trueOffset) * -1.0
    }
    
    private func currentScrollOffSet(activePageIndex: Int, dragOffset: CGFloat) -> CGFloat {
        return self.offsetForPageIndex(activePageIndex) + dragOffset
    }
    
    private func offsetForPageIndex(_ index: Int) -> CGFloat {
        return -self.baseTileOffset(index: index)
    }
    
    private func baseTileOffset(index: Int) -> CGFloat {
        return CGFloat(index) * (tileWidth + tilePadding)
    }
}
