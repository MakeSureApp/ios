//
//  NotificationModel.swift
//  MakeSure
//
//  Created by Macbook Pro on 19.06.2023.
//

import Foundation

struct NotificationModel: Identifiable, Codable {
    var id: UUID
    var userId: UUID
    var title: String
    var description: String?
    var createdAt: Date
    var isNotified: Bool
    
    private enum CodingKeys: String, CodingKey {
        case id, title, description, createdAt = "created_at", userId = "user_id", isNotified = "is_notified"
    }
}
