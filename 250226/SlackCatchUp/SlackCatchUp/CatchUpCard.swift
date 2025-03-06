//
//  CatchUpCard.swift
//  SlackCatchUp
//
//  Created by KOVI on 2/25/25.
//

import SwiftUI

final class CardVM: ObservableObject {
    @Published var rotationAngle: Angle = .zero
    @Published var startLocation: CGPoint?
    @Published var dragOffset: CGSize = .zero
    @Published var readStatePercentage: CGFloat = .zero
}

struct CatchUpCard: View {
    // 뷰모델을 사용하는 기준
    // @ObservedObject 와 @StateObject의 차이: 상위객체, 하위객체와의 관계 파악
    @ObservedObject private var cardVM = CardVM()
    private let cardImage = UIImage(named: "firstcard")!
    
    var body: some View {
        VStack {
            Spacer()
            
            ZStack {
                Image(uiImage: cardImage)
                    .resizable()
                    .overlay(overlayRectangle)
                    .offset(cardVM.dragOffset)
                    .rotationEffect(cardVM.rotationAngle)
                    .simultaneousGesture(createDragGesture())
            }
            
            buttons
        }
    }
    
    // MARK: subviews
    
    private var buttons: some View {
        HStack(spacing: 5) {
            Button {
                
            } label: {
                ZStack {
                    Color.unread
                    Text("읽지 않음으로 표시")
                        .bold()
                        .foregroundColor(.white)
                }
            }
            .cornerRadius(10)
            .frame(maxWidth: .infinity)
            
            Button {
                
            } label: {
                ZStack {
                    Color.read
                    Text("읽음으로 표시")
                        .bold()
                        .foregroundColor(.white)
                }
            }
            .cornerRadius(10)
            .frame(maxWidth: .infinity)
        }
        .frame(height: 50)
    }
    
    private var overlayRectangle: some View {
        let readStatePercentage = cardVM.readStatePercentage

        let opacityValue = abs(readStatePercentage) / 100 * 0.95
        let progress = abs(readStatePercentage) / 100
        let strokeWidth: CGFloat = 8
        let circleSize: CGFloat = 80

        return ZStack(alignment: readStatePercentage >= 0 ? .topLeading : .topTrailing) {
            Rectangle()
                .fill(readStatePercentage >= 0 ? Color.green : Color.blue)
                .opacity(opacityValue)

            if readStatePercentage != 0 {
                VStack {
                    ZStack {
                        Circle()
                            .stroke(lineWidth: strokeWidth)
                            .foregroundColor(.clear)
                            .frame(width: circleSize, height: circleSize)
                            .overlay(
                                Circle()
                                    .trim(from: 0, to: progress)
                                    .stroke(style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                                    .foregroundColor(.white)
                                    .frame(width: circleSize, height: circleSize)
                                    .rotationEffect(.degrees(-90))
                            )
                        
                        Text("\(Int(abs(readStatePercentage)))%")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(16)
                    
                    Text(readStatePercentage < 0 ? "읽지 않음\n으로 표시" : "읽음으로\n표시")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                        .padding(20)
                }
            }
        }
    }
    
    // MARK: gesture
    
    private func createDragGesture() -> some Gesture {
        DragGesture()
            .onChanged { value in
                handleDragChanged(value: value)
            }
            .onEnded { _ in
                handleDragEnded()
            }
    }
    
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
    
    private func handleDragEnded() {
        // 4. 원래 자리로 초기화 및 시작점 초기화
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            cardVM.rotationAngle = .zero
            cardVM.dragOffset = .zero
        }
        
        cardVM.startLocation = nil
        cardVM.readStatePercentage = .zero
    }
}

#Preview {
    CatchUpCard()
}

//    private func rotationDragGesture(frame: CGRect) -> some Gesture {
//        DragGesture(minimumDistance: 0)
//            .onChanged { value in
//                // 드래그에 따른 offset 업데이트
//                dragOffset = value.translation
//
//                // 뷰의 중앙을 기준으로 회전 각도를 계산
//                let center = CGPoint(x: frame.midX, y: frame.midY)
//                let deltaX = value.location.x - center.x
//                let deltaY = value.location.y - center.y
//                someAngle = Angle(radians: Double(atan2(deltaY, deltaX)))
//            }
//            .onEnded { _ in
//                // 드래그 종료 시, 회전과 offset 모두 원점으로 복귀
//                withAnimation(.easeOut) {
//                    dragOffset = .zero
//                    someAngle = .zero
//                }
//            }
//    }



//                .offset(dragOffset)
//                .gesture(rotationDragGesture(frame: frame))


//                        RotationGesture()
//                            .onChanged { value in
//                                guard !value.radians.isNaN else { return }
//                                // 1radians = 57.2958
//                                // 180도(degree) = 3.14 radians
//                                print(value.radians)
//                                print(value.degrees)
//                                mapVM.rotationAngle = value
//                            }
//                            .onEnded { _ in
//                                mapVM.lastAngle += mapVM.rotationAngle
//                                mapVM.rotationAngle = .zero
//                            }


//struct Area: View {
//    let index: Int
//    @ObservedObject var mapVM: MapVM
//
//    var body: some View {
//        GeometryReader { localGeometry in
//            ZStack {
//                Color.red.opacity(0.1)
//                    .cornerRadius(10)
//                    .simultaneousGesture(
//                        DragGesture(minimumDistance: 0)
//                            .onChanged { value in
//                                let globalPosition = CGPoint(
//                                    x: value.location.x + localGeometry.frame(in: .named("MapGeometry")).origin.x,
//                                    y: value.location.y + localGeometry.frame(in: .named("MapGeometry")).origin.y
//                                )
//                                mapVM.updateFingerPosition(index: index, global: globalPosition, local: value.location)
//                            }
//                            .onEnded { _ in
//                                mapVM.clearFinger(index: index)
//                            }
//                    )
//
//                if let position = mapVM.fingerLocal[index] {
//                    Circle()
//                        .fill(Color.yellow)
//                        .frame(width: 30, height: 30)
//                        .position(position)
//                        .overlay(
//                            Text("\(index)")
//                                .foregroundColor(.white)
//                                .bold()
//                        )
//                }
//            }
//        }
//        .coordinateSpace(name: "AreaGeometry")
//        .padding()
//    }
//}
