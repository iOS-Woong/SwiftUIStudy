//
//  FloatingSheet.swift
//  RubberBandBottomSheet
//
//  Created by KOVI on 1/10/25.
//

import SwiftUI
import UIKit

extension View {
    @ViewBuilder
    func floatingBottomSheet<Content: View>(
        isPresented: Binding<Bool>,
        content: @escaping () -> Content) -> some View
    {
        self.sheet(isPresented: isPresented) {
            content()
                .presentationBackground(.clear)
                .presentationDragIndicator(.visible)
                .background(SheetShadowRemover())
        }
    }
}

fileprivate extension UIView {
    var viewBeforeWindow: UIView? {
        if let superview, superview is UIWindow {
            return self
        }
        
        return superview?.viewBeforeWindow
    }
}

fileprivate struct SheetShadowRemover: UIViewRepresentable {
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        
        DispatchQueue.main.async {
            if let uiSheetView = view.viewBeforeWindow {
                for view in uiSheetView.subviews {
                    view.layer.shadowColor = UIColor.clear.cgColor
                }
            }
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
    
}


struct FloatingSheet: View {
    var body: some View {
        Text("Hello, World!")
    }
}

#Preview {
    FloatingSheet()
}
