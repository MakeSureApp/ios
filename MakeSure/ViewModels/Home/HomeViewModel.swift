//
//  HomeViewModel.swift
//  MakeSure
//
//  Created by andreydem on 4/24/23.
//

import Foundation
import SwiftUI

enum Category: String, CaseIterable {
    case health = "Health"
    case dates = "Dates"
    case selfDevelopment = "Self-development"
    
    var color: Color {
        switch self {
        case .health:
            return Color(red: 0, green: 23/255, blue: 119/255)
        case .dates:
            return Color(red: 105/255, green: 76/255, blue: 219/255)
        case .selfDevelopment:
            return Color(red: 112/255, green: 39/255, blue: 110/255)
        }
    }
}

class HomeViewModel: ObservableObject {
    
    @Published var testsDone: Int = 5
    @Published var name: String = "JANE"
    @Published var age: Int = 28
    @Published var tipCategories: [Category] = [.health, .dates, .selfDevelopment]
    @Published var selectedCategories: [Category] = []
    @Published var cards: [Card] = [] 
    
    var filteredCards: [Card] {
        if selectedCategories.isEmpty {
            return cards
        } else {
            return cards.filter { selectedCategories.contains($0.category) }
        }
    }
    
    init() {
        cards.append(Card(title: "Safe tips for Speed Dating", description: "How to talk to a partner about tests?", image: "mockTipsImage", category: .dates, url: "https://example.com/1"))
        cards.append(Card(title: "Keep safe & keep romantic", description: nil, image: "mockTipsImage2", category: .selfDevelopment, url: ""))
        cards.append(Card(title: "Sex education: what you need to know", description: nil, image: "mockTipsImage", category: .health, url: "https://example.com/3"))
    }
    
    func orderNewBoxClicked() {
        print("Order new box")
    }
    
    func openTipsDetails(_ urlStr: String) {
        if let url = URL(string: urlStr) {
            UIApplication.shared.open(url)
        }
    }
}
