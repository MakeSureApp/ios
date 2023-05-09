//
//  Meeting.swift
//  MakeSure
//
//  Created by andreydem on 5/3/23.
//

import Foundation

struct MeetingModel: Codable {
    var userId: UUID
    var date: Date
    var partnerId: UUID
    
    private enum CodingKeys: String, CodingKey {
        case userId = "user_id", date = "meeting_date", partnerId = "participant_b"
    }
}
