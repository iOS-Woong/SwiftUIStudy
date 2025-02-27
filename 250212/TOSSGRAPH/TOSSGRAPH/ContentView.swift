//
//  ContentView.swift
//  TOSSGRAPH
//
//  Created by KOVI on 2/12/25.
//

import SwiftUI

struct ContentView: View {
    @State private var totalAmount: CGFloat = 0
    @State private var stackedBarData: [SpendingCategory] = []
    @State private var visibleBarIDs: Set<UUID> = [] // 애니메이션 할 Bar의 ID를 담아두기 위한 객체
    
    private let maxWidth: CGFloat = 300
    
    var body: some View {
        
        VStack(spacing: 20) {
            Spacer()
            
            totalAmountText
            barchart
            sortedCategoryListView
            
            Spacer()
            
            resetButton
            
            Spacer()
        }
        .background(Color.coverBackground)
        .onAppear {
            generateRandomData()
            animateBarsSequentially()
        }
    }
    
    // MARK: subviews
    
    private var totalAmountText: some View {
        HStack(spacing: 3) {
            Text(totalAmount, format: .number)
                .foregroundColor(.white)
                .font(.title)
                .monospacedDigit()
                .contentTransition(.numericText())
                .transaction { transac in
                    transac.animation = .default
                }
            
            Text("원")
                .font(.title)
                .foregroundColor(.white)
        }
    }
    
    private var barchart: some View {
        ZStack(alignment: .trailing) {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.3))
            
            HStack(spacing: 2) {
                ForEach(stackedBarData) { category in
                    // MARK: .asymmetric 사용 코드 주석 (사용시 주석 해제)
//                    if visibleBarIDs.contains(category.id) {
                        let barWidth = (category.amount / totalAmount) * maxWidth
                        
                        Rectangle()
                            .fill(category.type.color)
                            .frame(width: barWidth, height: 30)
                    // MARK: .animation 사용 코드
                            .offset(x: visibleBarIDs.contains(category.id) ? 0 : maxWidth)
                            .animation(.smooth, value: visibleBarIDs)
                    // MARK: .asymmetric 사용 코드 주석 (사용시 주석 해제)
//                            .transition(.asymmetric(
//                                insertion: .move(edge: .trailing).animation(.smooth),
//                                removal: .opacity.animation(.easeIn(duration: 0.2)))
//                            )
//                    }
                    
                }
            }
            .padding(.horizontal, 4)
        }
        .frame(width: maxWidth, height: 30)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private var sortedCategoryListView: some View {
        VStack(spacing: 12) {
            ForEach(stackedBarData) { category in
                let ratio = totalAmount == 0 ? 0 : (category.amount / totalAmount)
                
                HStack {
                    HStack {
                        Circle()
                            .fill(category.type.color)
                            .frame(width: 10, height: 10)
                        
                        Text(category.type.rawValue)
                            .foregroundColor(.white)
                        
                        Text(ratio, format: .percent.precision(.fractionLength(1)))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    
                    Text("\(Int(category.amount))원")
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    private var resetButton: some View {
        Button("변경") {
            resetData()
        }
        .padding()
        .foregroundColor(.white)
        .background(Color.blue)
        .cornerRadius(8)
    }
    
    // MARK: logic
    
    private func generateRandomData() {
        var newData: [SpendingCategory] = []
        
        for category in SpendingCategoryType.allCases {
            let randomAmount = CGFloat(Int.random(in: 100000...300000))
            
            newData.append(SpendingCategory(type: category, amount: randomAmount))
        }
        var sumAll: CGFloat = .zero
        newData.forEach { sumAll += $0.amount }
        
        totalAmount = sumAll
        stackedBarData = newData.sorted(by: { $0.amount > $1.amount })
    }
    
    private func animateBarsSequentially() {
        withAnimation {
            visibleBarIDs.removeAll()
        }

        for (index, bar) in stackedBarData.enumerated() {
            let delayPerIndex = Double(index) * 0.2
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delayPerIndex) {
                withAnimation {
                    let _ = visibleBarIDs.insert(bar.id)
                }
            }
        }
    }
    
    private func resetData() {
        generateRandomData()
        animateBarsSequentially()
    }
}

#Preview {
    ContentView()
}
