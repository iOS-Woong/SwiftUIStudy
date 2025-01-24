//
//  ContentView.swift
//  JoinOpenChat
//
//  Created by KOVI on 1/22/25.
//

import SwiftUI
import UIKit
import SnapKit

struct ContentView: View {
    @State private var showSheet = false
    @State private var currentSheetHeight: CGFloat = .zero
    
    var body: some View {
        VStack {
            Button {
                showSheet.toggle()
            } label: {
                Text("Show Sheet")
                    .foregroundColor(.black)
            }
        }
        .sheet(isPresented: $showSheet) {
            ZStack {
                GeometryReader { geometry in
                    ChatDescView()
                        .onChange(of: geometry.size) { newValue in
                            currentSheetHeight = geometry.size.height
                        }
                }
            }
            .presentationDetents([.medium, .height(650)])
            .interactiveDismissDisabled(true)
            .background(NightCityBackgroundView(currentSheetHeight: $currentSheetHeight))
        }
    }
}

fileprivate extension UIView {
    static var count = 0
    
    var viewBeforeWindow: UIView? {
        if let superview, superview is UIWindow {
            return self
        }
//        print(superview)
//        print(superview?.viewBeforeWindow)
        
        return superview?.viewBeforeWindow
    }
}

fileprivate struct NightCityBackgroundView: UIViewRepresentable {
    
    @Binding var currentSheetHeight: CGFloat
    
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        
        DispatchQueue.main.async {
            if let uiSheetView = containerView.viewBeforeWindow {
                print(uiSheetView)
                let backgroundView = UIHostingController(
                    rootView: SwiftUINightCitySheetContainerView(
                        currentSheetHeight: $currentSheetHeight
                    )
                )
                let hostedView = backgroundView.view!
                
                hostedView.frame = uiSheetView.bounds
                uiSheetView.insertSubview(hostedView, at: .zero)
                
                let symbolConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold, scale: .default)
                
                let closeButton = UIButton()
                let closeImage = UIImage(systemName: "xmark", withConfiguration: symbolConfig)
                closeButton.tintColor = .white
                closeButton.setImage(closeImage, for: .normal)
                
                let shareButton = UIButton()
                let shareImage = UIImage(systemName: "square.and.arrow.up", withConfiguration: symbolConfig)
                shareButton.tintColor = .white
                shareButton.setImage(shareImage, for: .normal)
                
                uiSheetView.addSubview(shareButton)
                uiSheetView.addSubview(closeButton)
                
                closeButton.snp.makeConstraints {
                    $0.width.height.equalTo(24)
                    $0.top.equalTo(uiSheetView).offset(60)
                    $0.leading.equalTo(uiSheetView).offset(20)
                }
                
                shareButton.snp.makeConstraints {
                    $0.width.height.equalTo(24)
                    $0.top.equalTo(uiSheetView).offset(60)
                    $0.trailing.equalTo(uiSheetView).offset(-20)
                }
            }
        }
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
    }
}


#Preview {
    ContentView()
}
