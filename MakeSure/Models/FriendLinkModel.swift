//
//  FriendLinkModel.swift
//  MakeSure
//
//  Created by andreydem on 5/13/23.
//

import Foundation

struct FriendLinkModel: Codable {
    var id: UUID
    var createdAt: Date
    var userId: UUID
    
    private enum CodingKeys: String, CodingKey {
        case id, createdAt = "created_at", userId = "user_id"
    }
}
