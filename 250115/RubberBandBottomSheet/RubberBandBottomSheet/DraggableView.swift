//
//  DraggableView.swift
//  RubberBandBottomSheet
//
//  Created by KOVI on 1/13/25.
//
import SwiftUI

struct DraggableMessage {
    var finalTransitionValue: CGSize? = nil
    var upwardDragRatio: CGFloat? = nil
    var horizontalDragRatio: CGFloat? = nil
}

struct DraggableView: View {
    
    var onDismiss: () -> Void
    var onChanged: (DraggableMessage) -> Void
    
    // @GestureState를 사용하여 드래그 상태를 추적
    @GestureState private var gestureOffset: CGSize = .zero
    // @State를 사용하여 최종 위치를 관리
    @State private var finalOffset: CGSize = .zero
    
    var body: some View {
        GeometryReader { proxy in
            
            // 이 외 컨텐츠 탭의 경우, dismiss를 처리하기 위한 Z스택
            ZStack {
                Color.black.opacity(0.0001)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        onDismiss()
                    }
                
                VStack {
                    Spacer()
                    
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
                        .padding(.bottom, proxy.safeAreaInsets.bottom)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    private func toPercentage(decelerated: CGFloat, limit: CGFloat) -> CGFloat {
        return abs(decelerated) / limit * 100
    }
}
