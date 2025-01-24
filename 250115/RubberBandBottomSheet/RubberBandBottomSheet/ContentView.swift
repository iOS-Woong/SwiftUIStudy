//
//  ContentView.swift
//  RubberBandBottomSheet
//
//  Created by KOVI on 1/10/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showSheet = false
    @State private var opacity: Double = 0.0
    @State private var draggingRate: (Int, Int) = (0, 0)
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 메인 콘텐츠
                VStack {
                    Spacer()
                    
                    Button("Show Sheet") {
                        withAnimation {
                            showSheet.toggle()
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.yellow)
                
                if showSheet {
                    backgroundView
                }
            }
            .floatingBottomSheet(isPresented: $showSheet) {
                DraggableView(
                    onDismiss: { showSheet = false },
                    onChanged: { message in
                        if let upwardingRatio = message.upwardDragRatio {
                            let changedOpacity = upwardingRatio / 100
                            opacity = changedOpacity
                            draggingRate.1 = Int(upwardingRatio)
                        }
                        
                        if let horizontalDragRatio = message.horizontalDragRatio {
                            draggingRate.0 = Int(horizontalDragRatio)
                        }
                        
                    }
                )
                .presentationDetents([.height(500)])
            }
        }
    }
    
    private var backgroundView: some View {
        ZStack {
            Color.black.opacity(opacity)
                .ignoresSafeArea()
                .animation(.easeInOut, value: opacity)
                .onTapGesture {
                    
                    withAnimation {
                        showSheet = false
                    }
                }
            
            Text("HorizntalDragginRate: \(draggingRate.0) %")
                .bold()
                .foregroundColor(.red)
                .offset(y: -350)
            
            Text("UpwardDraggingRate: \(draggingRate.1) %")
                .bold()
                .foregroundColor(.red)
                .offset(y: -300)
        }
    }
}

#Preview {
    ContentView()
}
