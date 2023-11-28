//
//  NotificationModel.swift
//  MakeSure
//
//  Created by Macbook Pro on 19.06.2023.
//

import Foundation
import SwiftUI

struct NotificationModel: Identifiable, Codable {
    var id: UUID
    var userId: UUID
    var title: String
    var description: String?
    var createdAt: Date
    var isNotified: Bool
    var author: String?
    
    private enum CodingKeys: String, CodingKey {
        case id, title, description, createdAt = "created_at", userId = "user_id", isNotified = "is_notified", author
    }
    
}

extension NotificationModel {
    @ViewBuilder
    func getIcon(userService: UserSupabaseService) -> some View {
        if let author {
            if author == "emergency" {
                Image("pharmacyIcon")
                    .resizable()
                    .frame(width: 45, height: 45)
            } else {
                if let userId = UUID(uuidString: author) {
                    UserIconView(userId: userId, userService: userService)
                } else {
                    Image("circleLogoIcon")
                        .resizable()
                        .frame(width: 45, height: 45)
                }
            }
        } else {
            Image("circleLogoIcon")
                .resizable()
                .frame(width: 45, height: 45)
        }
    }
}
