//
//  Card.swift
//  MakeSure
//
//  Created by andreydem on 4/26/23.
//

import Foundation

struct Card: Identifiable {
    let id = UUID()
    let title: String
    let description: String?
    let image: String
    let category: Category
    let url: String
}
