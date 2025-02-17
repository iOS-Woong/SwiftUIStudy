//
//  ToggleView.swift
//  YoutubeMusic
//
//  Created by KOVI on 2/17/25.
//

import SwiftUI

final class toggleVM: ObservableObject {
    init() {
        print("ToggleViewModel 생성됨")
    }
    
    deinit {
        print("ToggleViewModel 해제됨")
    }
}

struct ToggleView: View {
    @StateObject private var viewModel = toggleVM()
    @State private var toggle1: Bool = false
    @State private var toggle2: Bool = false
    @State private var toggle3: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Toggle("토글 1", isOn: $toggle1)
            Toggle("토글 2", isOn: $toggle2)
            Toggle("토글 3", isOn: $toggle3)
        }
        .padding()
    }
}
