//
//  Tips.swift
//  MakeSure
//
//  Created by andreydem on 5/5/23.
//

import Foundation
import SwiftUI

struct TipsModel: Identifiable, Codable {
    var id: UUID
    var createdAt: Date
    var title: String
    var description: String?
    var url: String
    var imageUrl: String
    var category: String
    
    private enum CodingKeys: String, CodingKey {
        case id, createdAt = "created_at", title, description, url = "link", imageUrl = "image_URL", category = "type"
    }
}
