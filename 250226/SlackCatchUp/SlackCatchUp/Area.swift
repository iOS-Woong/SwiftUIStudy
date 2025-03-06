//
//  Area.swift
//  SlackCatchUp
//
//  Created by KOVI on 2/26/25.
//

import SwiftUI

//struct Area: View {
//    let index: Int
//    @ObservedObject var catchUpcardVM: CatchUpCardVM
//    
//    var body: some View {
//        GeometryReader { localGeometry in
//            ZStack {
//                Color.black.opacity(0.1)
//                    .cornerRadius(10)
//                    .simultaneousGesture(
//                        DragGesture(minimumDistance: 0)
//                            .onChanged { value in
//                                let globalPosition = CGPoint(
//                                    x: value.location.x + localGeometry.frame(in: .named("MapGeometry")).origin.x,
//                                    y: value.location.y + localGeometry.frame(in: .named("MapGeometry")).origin.y
//                                )
//                                catchUpcardVM.updateFingerPosition(index: index, global: globalPosition, local: value.location)
//                            }
//                            .onEnded { _ in
//                                catchUpcardVM.clearFinger(index: index)
//                            }
//                    )
//                
//                if let position = catchUpcardVM.fingerLocal[index] {
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
