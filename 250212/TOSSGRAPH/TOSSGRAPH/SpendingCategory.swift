//
//  SpendingCategory.swift
//  TOSSGRAPH
//
//  Created by KOVI on 2/12/25.
//

import SwiftUI

// MARK: SpendingCategoryType Enum 관련
enum SpendingCategoryType: String, CaseIterable, Identifiable {
    case transfer       = "이체"
    case shopping       = "쇼핑"
    case convenience    = "편의점/마트/잡화"
    case uncategorized  = "카테고리 없음"
    case others         = "그 외"
    
    var id: String { self.rawValue }
    
    var color: Color {
        switch self {
        case .transfer:      return Color.transfer
        case .shopping:      return Color.shopping
        case .convenience:   return Color.convenience
        case .uncategorized: return Color.uncategorized
        case .others:        return Color.others
        }
    }
}

// MARK: SpendingCategory 관련
struct SpendingCategory: Identifiable {
    var id = UUID()
    var type: SpendingCategoryType
    var amount: CGFloat
}
