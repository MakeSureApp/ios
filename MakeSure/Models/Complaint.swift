//
//  Complaint.swift
//  MakeSure
//
//  Created by Macbook Pro on 06.12.2023.
//

import Foundation

struct Complaint: Codable {
    var id: UUID
    var createdAt: Date
    var userId: UUID
    var myUserId: UUID
    var text: String
    
    private enum CodingKeys: String, CodingKey {
        case id, myUserId = "from_user_id", createdAt = "created_at", userId = "user_id", text
    }
}
