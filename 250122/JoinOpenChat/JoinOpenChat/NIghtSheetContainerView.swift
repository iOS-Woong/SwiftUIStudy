//
//  NIghtSheetContainerView.swift
//  JoinOpenChat
//
//  Created by KOVI on 1/22/25.
//

import SwiftUI

struct SwiftUINightCitySheetContainerView: View {
    
    @Binding var currentSheetHeight: CGFloat
    
    private let adjustImageOffset: CGFloat = 300
    
    var body: some View {
        ZStack {
            backgroundImage
            
            VStack(alignment: .leading) {
                topDissapearableRoomDescView
                Spacer()
                middlePullUpRoomDescView
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private var topDissapearableRoomDescView: some View {
        roomDescView
            .opacity(currentSheetHeight >= 650 ? 1.0 : 0)
            .animation(.easeInOut, value: currentSheetHeight)
            .padding(.top, 50)
    }
    
    private var middlePullUpRoomDescView: some View {
        roomDescView
            .offset(y: -currentSheetHeight)
            .opacity(opacityForSheetHeight(currentSheetHeight))
            .padding(.bottom, 20)
    }
    
    private var roomDescView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("iOS SwiftUI UI 스터디")
                .font(.title)
                .foregroundColor(.white)
            
            HStack(spacing: 6) {
                Text("그룹채팅")
                Text("·")
                Text("참여자 6/1500")
                Text("·")
                Text("개설일 2024.1.22")
            }
            .font(.subheadline.bold())
            .foregroundColor(.white)
        }
    }
    
    private var backgroundImage: some View {
        Image("night")
            .resizable()
            .scaledToFill()
            .offset(y: -currentSheetHeight + adjustImageOffset)
    }
    
    func opacityForSheetHeight(_ height: CGFloat) -> CGFloat {
        let minHeight: CGFloat = 430
        let maxHeight: CGFloat = 650
        
        let clamped = max(min(height, maxHeight), minHeight)
        let ratio = (clamped - minHeight) / (maxHeight - minHeight)
        
        return 1 - ratio
    }
}

#Preview {
    SwiftUINightCitySheetContainerView(currentSheetHeight: .constant(.zero))
}
