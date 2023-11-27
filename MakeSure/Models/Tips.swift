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
    var titleRu: String
    var descriptionRu: String?
    var url: String
    var urlRu: String
    var imageUrl: String
    var category: String
    var categoryRu: String
    
    private enum CodingKeys: String, CodingKey {
        case id, createdAt = "created_at", title, titleRu = "title_ru", description, descriptionRu = "description_ru", url = "link", urlRu = "link_ru", imageUrl = "image_URL", category = "type", categoryRu = "type_ru"
    }
    
    var displayTitle: String {
        return appEnvironment.localizationManager.getLanguage() == .RU ? titleRu : title
    }
    
    var displayDescription: String? {
        return appEnvironment.localizationManager.getLanguage() == .RU ? descriptionRu : description
    }
    
    var displayUrl: String {
        return appEnvironment.localizationManager.getLanguage() == .RU ? urlRu : url
    }
    
    var displayCategory: String {
        return appEnvironment.localizationManager.getLanguage() == .RU ? categoryRu : category
    }
}

struct BilingualCategory: Hashable {
    let english: String
    let russian: String
}
