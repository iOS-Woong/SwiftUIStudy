//
//  ChatDescView.swift
//  JoinOpenChat
//
//  Created by KOVI on 1/22/25.
//

import SwiftUI

struct ChatDescView: View {
    var body: some View {
        ZStack(alignment: .top) {
            VStack(alignment: .leading) {
                userProfile
                hashTags
                
                Spacer()
                
                joinButton
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(.descBackground)
    }
    
    private var userProfile: some View {
        HStack {
            Image(.userProfile)
                .resizable()
                .frame(width: 50, height: 42)
            Text(Constant.userNick)
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding()
    }
    
    private var hashTags: some View {
        Text(Constant.tag)
            .foregroundColor(.white)
            .padding()
    }
    
    private var joinButton: some View {
        Button {
            print("오픈채팅 참여되었음")
        } label: {
            ZStack {
                Text("오픈채팅 참여하기")
                    .foregroundColor(.black)
            }
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(Color.button)
        }
    }
    
    enum Constant {
        static let userNick = "서현웅/iOS"
        static let tag = """
        #AppDelegate #SceneDelegate #UIKit #SwiftUI #Combine #CoreData #ARKit #CoreML #MapKit #SpriteKit #CoreLocation #Metal #UserDefaults #NotificationCenter #URLSession #AVFoundation #StoreKit #CryptoKit #MultipeerConnectivity #KeychainAppDelegate #SceneDelegate #UIKit #SwiftUI #Combine #CoreData #ARKit #CoreML #MapKit #SpriteKit #CoreLocation #Metal #UserDefaults #NotificationCenter #URLSession #AVFoundation #StoreKit #CryptoKit #MultipeerConnectivity #KeychainAppDelegate #SceneDelegate #UIKit #SwiftUI #Combine #CoreData #ARKit #CoreML #MapKit #SpriteKit #CoreLocation #Metal #UserDefaults #NotificationCenter #URLSession #AVFoundation #StoreKit #CryptoKit #MultipeerConnectivity #KeychainAppDelegate #SceneDelegate #UIKit #SwiftUI #Combine #CoreData #ARKit #CoreML #MapKit #SpriteKit #CoreLocation #Metal #UserDefaults #NotificationCenter #URLSession #AVFoundation #StoreKit #CryptoKit #MultipeerConnectivity #KeychainAppDelegate #SceneDelegate #UIKit #SwiftUI #Combine #CoreData #ARKit #CoreML #MapKit #SpriteKit #CoreLocation #Metal #UserDefaults #NotificationCenter #URLSession #AVFoundation #StoreKit #CryptoKit #MultipeerConnectivity #Keychain
        """
    }
}


#Preview {
    ChatDescView()
}
