//
//  ContentView.swift
//  SlackCatchUp
//
//  Created by KOVI on 2/25/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink("따라잡기 7 새 항목") {
                    CatchUpCard()
                        .navigationTitle("7개 남음")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
